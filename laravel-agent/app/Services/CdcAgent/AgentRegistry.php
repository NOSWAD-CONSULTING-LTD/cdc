<?php

namespace App\Services\CdcAgent;

use RuntimeException;

class AgentRegistry
{
    public function rootPath(): string
    {
        $root = realpath(base_path('..'));

        if ($root === false) {
            throw new RuntimeException('Could not resolve CDC project root.');
        }

        return $root;
    }

    /**
     * @return array<int, array<string, mixed>>
     */
    public function questions(): array
    {
        return $this->loadJson(resource_path('cdc-agent/questions.json'));
    }

    /**
     * @return array<string, array<string, mixed>>
     */
    public function expectations(): array
    {
        return $this->keyBy($this->loadJson(resource_path('cdc-agent/expected_answers.json')), 'question_id');
    }

    /**
     * @return array<string, array<string, mixed>>
     */
    public function templates(): array
    {
        return $this->keyBy($this->loadJson(resource_path('cdc-agent/query_templates.json')), 'template_id');
    }

    /**
     * @return array<string, mixed>
     */
    public function questionById(string $questionId): array
    {
        foreach ($this->questions() as $question) {
            if (($question['id'] ?? null) === $questionId) {
                return $question;
            }
        }

        throw new RuntimeException("No question found for {$questionId}.");
    }

    /**
     * @return array<string, mixed>
     */
    public function selectQuestion(string $question, ?string $questionId = null): array
    {
        if ($questionId !== null) {
            return $this->questionById($questionId);
        }

        $bestQuestion = null;
        $bestScore = 0;
        $terms = $this->terms($question);

        foreach ($this->questions() as $candidate) {
            $candidateText = implode(' ', [
                $candidate['id'] ?? '',
                $candidate['question'] ?? '',
                $candidate['intent'] ?? '',
                $candidate['template_id'] ?? '',
                implode(' ', $candidate['answer_requirements'] ?? []),
            ]);

            $score = $this->score($terms, $candidateText);

            if ($score > $bestScore) {
                $bestQuestion = $candidate;
                $bestScore = $score;
            }
        }

        if ($bestQuestion === null || $bestScore === 0) {
            throw new RuntimeException('No approved question/template matched the request.');
        }

        return $bestQuestion;
    }

    /**
     * @param  array<string, mixed>  $question
     * @param  array<string, mixed>  $template
     */
    public function validateQuestion(array $question, array $template): void
    {
        $required = $template['params'] ?? [];
        $provided = array_keys($question['parameters'] ?? []);

        $missing = array_values(array_diff($required, $provided));
        $extra = array_values(array_diff($provided, $required));

        if ($missing !== [] || $extra !== []) {
            throw new RuntimeException(sprintf(
                'Parameter mismatch for %s using %s: missing=%s extra=%s',
                $question['id'],
                $template['template_id'],
                json_encode($missing),
                json_encode($extra),
            ));
        }
    }

    /**
     * @return array<int, array<string, mixed>>
     */
    private function loadJson(string $path): array
    {
        if (! is_file($path)) {
            throw new RuntimeException("Missing JSON file: {$path}");
        }

        $decoded = json_decode((string) file_get_contents($path), true);

        if (! is_array($decoded)) {
            throw new RuntimeException("Invalid JSON file: {$path}");
        }

        return $decoded;
    }

    /**
     * @param  array<int, array<string, mixed>>  $items
     * @return array<string, array<string, mixed>>
     */
    private function keyBy(array $items, string $key): array
    {
        $result = [];

        foreach ($items as $item) {
            if (! isset($item[$key]) || ! is_string($item[$key])) {
                throw new RuntimeException("Missing key {$key} in JSON registry.");
            }

            $result[$item[$key]] = $item;
        }

        return $result;
    }

    /**
     * @return array<int, string>
     */
    private function terms(string $text): array
    {
        $words = preg_split('/[^a-z0-9]+/', mb_strtolower($text)) ?: [];

        return array_values(array_unique(array_filter(
            $words,
            fn (string $word): bool => mb_strlen($word) > 2,
        )));
    }

    /**
     * @param  array<int, string>  $terms
     */
    private function score(array $terms, string $text): int
    {
        $haystack = mb_strtolower($text);
        $score = 0;

        foreach ($terms as $term) {
            if (str_contains($haystack, $term)) {
                $score++;
            }
        }

        return $score;
    }
}
