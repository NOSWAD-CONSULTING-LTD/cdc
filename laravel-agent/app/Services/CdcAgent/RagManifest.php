<?php

namespace App\Services\CdcAgent;

use RuntimeException;

class RagManifest
{
    /**
     * @return array<int, array<string, mixed>>
     */
    public function retrieve(string $root, string $question, int $limit = 4): array
    {
        $path = $root.'/docs/rag-manifest.jsonl';

        if (! is_file($path)) {
            throw new RuntimeException("Missing RAG manifest: {$path}");
        }

        $terms = $this->terms($question);
        $records = [];

        foreach (file($path, FILE_IGNORE_NEW_LINES | FILE_SKIP_EMPTY_LINES) ?: [] as $line) {
            $record = json_decode($line, true);

            if (! is_array($record)) {
                continue;
            }

            $searchText = implode(' ', [
                $record['title'] ?? '',
                $record['summary'] ?? '',
                $record['retrieval_text'] ?? '',
                implode(' ', $record['answers'] ?? []),
                implode(' ', $record['tags'] ?? []),
            ]);

            $score = $this->score($terms, $searchText);

            if ($score === 0) {
                continue;
            }

            $record['score'] = $score;
            $records[] = $record;
        }

        usort($records, function (array $left, array $right): int {
            return [
                -($left['score'] ?? 0),
                $left['source_priority'] ?? 99,
                $left['chunk_id'] ?? '',
            ] <=> [
                -($right['score'] ?? 0),
                $right['source_priority'] ?? 99,
                $right['chunk_id'] ?? '',
            ];
        });

        return array_slice(array_map(
            fn (array $record): array => [
                'chunk_id' => $record['chunk_id'] ?? null,
                'path' => $record['path'] ?? null,
                'title' => $record['title'] ?? null,
                'content_type' => $record['content_type'] ?? null,
                'summary' => $record['summary'] ?? null,
                'source_priority' => $record['source_priority'] ?? null,
                'score' => $record['score'] ?? 0,
            ],
            $records,
        ), 0, $limit);
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
