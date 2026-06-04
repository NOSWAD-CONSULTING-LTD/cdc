<?php

namespace App\Ai\Agents;

use Illuminate\Contracts\JsonSchema\JsonSchema;
use Laravel\Ai\Contracts\Agent;
use Laravel\Ai\Contracts\HasStructuredOutput;
use Laravel\Ai\Promptable;
use Stringable;

class CdcEvidenceAgent implements Agent, HasStructuredOutput
{
    use Promptable;

    public function instructions(): Stringable|string
    {
        return implode("\n", [
            'You answer questions about the CDC pharmaceutical manufacturing knowledge graph.',
            'Use only the approved Cypher result rows and retrieved project documents supplied in the prompt.',
            'Do not invent process evidence, regulatory claims, material genealogy, deviations, or QA decisions.',
            'If evidence rows are empty, say there is insufficient evidence instead of guessing.',
            'Always keep the demo limitation clear: this is a reference architecture, not a validated GxP system.',
        ]);
    }

    public function schema(JsonSchema $schema): array
    {
        return [
            'status' => $schema->string()->enum(['answered', 'insufficient_evidence'])->required(),
            'answer' => $schema->string()->required(),
            'confidence' => $schema->string()->enum(['low', 'medium', 'high'])->required(),
            'limitations' => $schema->array()->items($schema->string())->required(),
        ];
    }
}
