<?php

namespace App\Services\CdcAgent;

use RuntimeException;

class CdcAgentService
{
    public function __construct(
        private readonly AgentRegistry $registry,
        private readonly CypherRunner $cypherRunner,
        private readonly RagManifest $ragManifest,
    ) {}

    /**
     * @return array<int, array{id: mixed, question: mixed, template_id: mixed, intent: mixed}>
     */
    public function listQuestions(): array
    {
        return array_map(
            fn (array $question): array => [
                'id' => $question['id'] ?? null,
                'question' => $question['question'] ?? null,
                'template_id' => $question['template_id'] ?? null,
                'intent' => $question['intent'] ?? null,
            ],
            $this->registry->questions(),
        );
    }

    /**
     * @return array<string, mixed>
     */
    public function ask(string $questionText, ?string $questionId = null): array
    {
        $root = $this->registry->rootPath();
        $question = $this->registry->selectQuestion($questionText, $questionId);
        $templates = $this->registry->templates();
        $expectations = $this->registry->expectations();
        $template = $templates[$question['template_id']] ?? null;

        if ($template === null) {
            throw new RuntimeException("Missing template {$question['template_id']}.");
        }

        $this->registry->validateQuestion($question, $template);

        $rows = $this->cypherRunner->run($root, $template['cypher'], $question['parameters'] ?? []);
        $documents = $this->ragManifest->retrieve($root, $questionText.' '.$question['question'], 4);
        $answer = $this->buildAnswer($questionText, $question, $template, $rows, $documents);
        $evaluation = $this->evaluateAnswer($answer, $expectations[$question['id']] ?? []);

        return [
            'answer' => $answer,
            'question_id' => $question['id'],
            'matched_question' => $question['question'],
            'intent' => $question['intent'],
            'template_id' => $question['template_id'],
            'parameters' => $question['parameters'] ?? [],
            'evidence' => $rows,
            'documents' => $documents,
            'evaluation' => $evaluation,
            'warnings' => [
                'This answer uses fictional demo data from the CDC Neo4j reference architecture.',
                'This is not a validated GxP system or real regulatory evidence.',
                'Only approved Cypher templates are used; arbitrary Cypher generation is disabled.',
            ],
        ];
    }

    /**
     * @param  array<string, mixed>  $question
     * @param  array<string, mixed>  $template
     * @param  array<int, array<string, string>>  $rows
     * @param  array<int, array<string, mixed>>  $documents
     */
    private function buildAnswer(string $userQuestion, array $question, array $template, array $rows, array $documents): string
    {
        $documentList = array_map(
            fn (array $document): string => ($document['path'] ?? 'unknown').' - '.($document['title'] ?? 'Untitled'),
            $documents,
        );

        return implode("\n", [
            'User question: '.$userQuestion,
            'Matched approved question: '.$question['question'],
            'Template: '.$template['template_id'],
            'Rows returned: '.count($rows),
            'Evidence: '.json_encode($rows, JSON_UNESCAPED_SLASHES | JSON_UNESCAPED_UNICODE),
            'Retrieved documents: '.json_encode($documentList, JSON_UNESCAPED_SLASHES | JSON_UNESCAPED_UNICODE),
            'Note: This answer uses fictional demo data from the CDC Neo4j reference architecture, not a validated GxP system.',
        ]);
    }

    /**
     * @param  array<string, mixed>  $expectation
     * @return array{passed: bool, missing: array<int, string>, prohibited: array<int, string>}
     */
    private function evaluateAnswer(string $answer, array $expectation): array
    {
        $answer = mb_strtolower($answer);
        $missing = [];
        $prohibited = [];

        foreach ($expectation['must_include'] ?? [] as $item) {
            if (! str_contains($answer, mb_strtolower((string) $item))) {
                $missing[] = (string) $item;
            }
        }

        foreach ($expectation['must_not_claim'] ?? [] as $item) {
            if (str_contains($answer, mb_strtolower((string) $item))) {
                $prohibited[] = (string) $item;
            }
        }

        return [
            'passed' => $missing === [] && $prohibited === [],
            'missing' => $missing,
            'prohibited' => $prohibited,
        ];
    }
}
