<?php

namespace App\Console\Commands;

use App\Services\CdcAgent\CdcAgentService;
use Illuminate\Console\Attributes\Description;
use Illuminate\Console\Attributes\Signature;
use Illuminate\Console\Command;
use RuntimeException;

#[Signature('cdc-agent:evaluate {--question= : Run one question ID} {--list : List available questions} {--show-answer : Print deterministic evidence answers}')]
#[Description('Evaluate approved CDC knowledge-graph agent questions against Neo4j')]
class CdcAgentEvaluate extends Command
{
    public function handle(CdcAgentService $agent): int
    {
        if ($this->option('list')) {
            foreach ($agent->listQuestions() as $question) {
                $this->line(sprintf(
                    '%s: %s [%s]',
                    $question['id'],
                    $question['question'],
                    $question['template_id'],
                ));
            }

            return self::SUCCESS;
        }

        $questionId = $this->option('question');
        $questions = $questionId === null
            ? $agent->listQuestions()
            : array_values(array_filter(
                $agent->listQuestions(),
                fn (array $question): bool => $question['id'] === $questionId,
            ));

        if ($questions === []) {
            $this->error("No question found for {$questionId}.");

            return self::FAILURE;
        }

        $failures = 0;

        foreach ($questions as $question) {
            try {
                $result = $agent->ask((string) $question['question'], (string) $question['id']);
            } catch (RuntimeException $exception) {
                $this->error("FAIL {$question['id']}: {$exception->getMessage()}");
                $failures++;

                continue;
            }

            $passed = (bool) ($result['evaluation']['passed'] ?? false);
            $line = sprintf(
                '%s %s template=%s rows=%d',
                $passed ? 'PASS' : 'FAIL',
                $result['question_id'],
                $result['template_id'],
                count($result['evidence']),
            );

            $passed ? $this->info($line) : $this->error($line);

            if (! $passed) {
                $this->line('  missing: '.json_encode($result['evaluation']['missing'], JSON_UNESCAPED_SLASHES));
                $this->line('  prohibited: '.json_encode($result['evaluation']['prohibited'], JSON_UNESCAPED_SLASHES));
                $failures++;
            }

            if ($this->option('show-answer')) {
                $this->newLine();
                $this->line($result['answer']);
                $this->newLine();
            }
        }

        return $failures === 0 ? self::SUCCESS : self::FAILURE;
    }
}
