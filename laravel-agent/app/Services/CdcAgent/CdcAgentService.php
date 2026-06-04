<?php

namespace App\Services\CdcAgent;

use RuntimeException;

class CdcAgentService
{
    public function __construct(
        private readonly AgentRegistry $registry,
        private readonly CypherRunner $cypherRunner,
        private readonly RagManifest $ragManifest,
        private readonly AiAnswerComposer $aiAnswerComposer,
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
        $answerContract = $this->buildAnswerContract($rows);
        $aiContext = $this->buildAiContext($questionText, $question, $template, $rows, $documents, $answerContract);
        $deterministicAnswer = $this->buildAnswer($questionText, $question, $template, $rows, $documents);
        $answer = $this->aiAnswerComposer->compose($aiContext, $deterministicAnswer);
        $evaluation = $this->evaluateAnswer($answer, $expectations[$question['id']] ?? []);

        return [
            'answer' => $answer,
            'ai_mode' => $this->aiAnswerComposer->mode(),
            'answer_contract' => $answerContract,
            'ai_context' => $aiContext,
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
     * @param  array<int, array<string, string>>  $rows
     * @return array{status: string, confidence: string, guardrails: array<int, string>, limitations: array<int, string>}
     */
    private function buildAnswerContract(array $rows): array
    {
        return [
            'status' => $rows === [] ? 'insufficient_evidence' : 'answered',
            'confidence' => $rows === [] ? 'low' : 'medium',
            'guardrails' => [
                'Use only returned Neo4j evidence rows and retrieved project documents.',
                'Do not generate arbitrary Cypher.',
                'Say insufficient evidence when graph rows are empty.',
                'Do not present demo data as validated GxP or real regulatory evidence.',
            ],
            'limitations' => [
                'Fictional CDC reference architecture data.',
                'Not a validated GxP system.',
                'Not a real product, regulatory filing, or manufacturing record.',
            ],
        ];
    }

    /**
     * @param  array<string, mixed>  $question
     * @param  array<string, mixed>  $template
     * @param  array<int, array<string, string>>  $rows
     * @param  array<int, array<string, mixed>>  $documents
     * @param  array<string, mixed>  $answerContract
     * @return array<string, mixed>
     */
    private function buildAiContext(string $questionText, array $question, array $template, array $rows, array $documents, array $answerContract): array
    {
        return [
            'question' => $questionText,
            'matched_question' => [
                'id' => $question['id'],
                'question' => $question['question'],
                'intent' => $question['intent'],
            ],
            'approved_template' => [
                'template_id' => $template['template_id'],
                'description' => $template['description'] ?? null,
                'params' => $template['params'] ?? [],
            ],
            'graph_evidence' => [
                'row_count' => count($rows),
                'rows' => $rows,
            ],
            'retrieved_documents' => array_map(
                fn (array $document): array => [
                    'chunk_id' => $document['chunk_id'] ?? null,
                    'path' => $document['path'] ?? null,
                    'title' => $document['title'] ?? null,
                    'summary' => $document['summary'] ?? null,
                ],
                $documents,
            ),
            'answer_contract' => $answerContract,
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
