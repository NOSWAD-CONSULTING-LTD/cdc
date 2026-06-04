<?php

namespace App\Services\CdcAgent;

use RuntimeException;
use Symfony\Component\Process\Process;

class CypherRunner
{
    /**
     * @param  array<string, mixed>  $params
     * @return array<int, array<string, string>>
     */
    public function run(string $root, string $cypher, array $params): array
    {
        $command = [
            'docker',
            'compose',
            'exec',
            '-T',
            'neo4j',
            'cypher-shell',
            '-u',
            config('neo4j_agent.username'),
            '-p',
            config('neo4j_agent.password'),
            '--access-mode',
            'read',
            '--format',
            'plain',
        ];

        if ($params !== []) {
            $command[] = '-P';
            $command[] = $this->cypherParamMap($params);
        }

        $command[] = $cypher;

        $process = new Process($command, $root);
        $process->setTimeout(30);
        $process->run();

        if (! $process->isSuccessful()) {
            throw new RuntimeException(trim($process->getErrorOutput() ?: $process->getOutput()));
        }

        return $this->parsePlainOutput($process->getOutput());
    }

    /**
     * @return array<int, array<string, string>>
     */
    private function parsePlainOutput(string $output): array
    {
        $lines = array_values(array_filter(
            preg_split('/\R/', $output) ?: [],
            fn (string $line): bool => trim($line) !== '',
        ));

        if ($lines === []) {
            return [];
        }

        $headers = array_map('trim', str_getcsv(array_shift($lines)));
        $rows = [];

        foreach ($lines as $line) {
            $values = array_map('trim', str_getcsv($line));
            $rows[] = array_combine($headers, $values) ?: [];
        }

        return $rows;
    }

    /**
     * @param  array<string, mixed>  $params
     */
    private function cypherParamMap(array $params): string
    {
        $parts = [];

        foreach ($params as $key => $value) {
            $parts[] = $key.': '.$this->cypherLiteral($value);
        }

        return '{'.implode(', ', $parts).'}';
    }

    private function cypherLiteral(mixed $value): string
    {
        if ($value === null) {
            return 'null';
        }

        if (is_bool($value)) {
            return $value ? 'true' : 'false';
        }

        if (is_int($value) || is_float($value)) {
            return (string) $value;
        }

        if (is_array($value)) {
            $items = [];

            foreach ($value as $item) {
                $items[] = $this->cypherLiteral($item);
            }

            return '['.implode(', ', $items).']';
        }

        return "'".str_replace(['\\', "'"], ['\\\\', "\\'"], (string) $value)."'";
    }
}
