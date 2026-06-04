<?php

namespace App\Services\CdcAgent;

use App\Ai\Agents\CdcEvidenceAgent;
use Illuminate\Support\Arr;
use Throwable;

class AiAnswerComposer
{
    /**
     * @param  array<string, mixed>  $context
     */
    public function compose(array $context, string $deterministicAnswer): string
    {
        if (! $this->enabled()) {
            return $deterministicAnswer;
        }

        try {
            $response = CdcEvidenceAgent::make()->prompt(
                prompt: $this->prompt($context),
                provider: config('cdc_agent.ai.provider'),
                model: config('cdc_agent.ai.model'),
                timeout: (int) config('cdc_agent.ai.timeout', 30),
            );

            $structured = method_exists($response, 'toArray') ? $response->toArray() : [];
            $answer = Arr::get($structured, 'answer');

            return is_string($answer) && $answer !== '' ? $answer : (string) $response;
        } catch (Throwable) {
            return $deterministicAnswer."\nAI composer fallback: provider call failed, so the deterministic evidence answer was returned.";
        }
    }

    public function mode(): string
    {
        return $this->enabled() ? 'laravel-ai-sdk' : 'deterministic';
    }

    private function enabled(): bool
    {
        return (bool) config('cdc_agent.ai.enabled', false);
    }

    /**
     * @param  array<string, mixed>  $context
     */
    private function prompt(array $context): string
    {
        return implode("\n\n", [
            'Create a concise answer from this CDC evidence package.',
            'Return structured output matching the configured schema.',
            json_encode($context, JSON_PRETTY_PRINT | JSON_UNESCAPED_SLASHES | JSON_UNESCAPED_UNICODE),
        ]);
    }
}
