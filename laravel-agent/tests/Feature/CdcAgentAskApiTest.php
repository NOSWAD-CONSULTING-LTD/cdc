<?php

namespace Tests\Feature;

use App\Services\CdcAgent\CypherRunner;
use Mockery\MockInterface;
use Tests\TestCase;

class CdcAgentAskApiTest extends TestCase
{
    public function test_it_answers_using_an_approved_template_and_returns_evidence(): void
    {
        $this->mock(CypherRunner::class, function (MockInterface $mock): void {
            $mock->shouldReceive('run')
                ->once()
                ->andReturn([
                    [
                        'neo4jType' => 'REJECTS',
                        'ontologyPredicate' => 'rejects',
                        'subjectLabel' => 'QAReleaseDecision',
                        'objectLabel' => 'ManufacturingRun',
                        'cardinalityNote' => 'Reference architecture guidance',
                        'description' => 'QA decision rejects a manufacturing run.',
                    ],
                ]);
        });

        $response = $this->postJson('/api/agent/ask', [
            'question' => 'What does REJECTS mean?',
            'question_id' => 'q013_relationship_definition',
        ]);

        $response
            ->assertOk()
            ->assertJsonPath('question_id', 'q013_relationship_definition')
            ->assertJsonPath('template_id', 'relationship_definition_lookup')
            ->assertJsonPath('evidence.0.neo4jType', 'REJECTS')
            ->assertJsonPath('evaluation.passed', true)
            ->assertJsonCount(3, 'warnings');

        $this->assertNotEmpty($response['documents']);
    }

    public function test_it_validates_the_question_payload(): void
    {
        $response = $this->postJson('/api/agent/ask', []);

        $response
            ->assertUnprocessable()
            ->assertJsonValidationErrors(['question']);
    }

    public function test_it_returns_not_found_for_unknown_question_id(): void
    {
        $response = $this->postJson('/api/agent/ask', [
            'question' => 'Unknown question',
            'question_id' => 'missing-question',
        ]);

        $response
            ->assertNotFound()
            ->assertJsonPath('message', 'No question found for missing-question.');
    }
}
