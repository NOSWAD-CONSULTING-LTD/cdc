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
            ->assertJsonPath('ai_mode', 'deterministic')
            ->assertJsonPath('answer_contract.status', 'answered')
            ->assertJsonPath('answer_contract.guardrails.0', 'Use only returned Neo4j evidence rows and retrieved project documents.')
            ->assertJsonPath('ai_context.question', 'What does REJECTS mean?')
            ->assertJsonPath('ai_context.approved_template.template_id', 'relationship_definition_lookup')
            ->assertJsonCount(3, 'warnings');

        $this->assertNotEmpty($response['documents']);
    }

    public function test_it_marks_answers_as_insufficient_when_the_graph_returns_no_evidence(): void
    {
        $this->mock(CypherRunner::class, function (MockInterface $mock): void {
            $mock->shouldReceive('run')
                ->once()
                ->andReturn([]);
        });

        $response = $this->postJson('/api/agent/ask', [
            'question' => 'What does REJECTS mean?',
            'question_id' => 'q013_relationship_definition',
        ]);

        $response
            ->assertOk()
            ->assertJsonPath('answer_contract.status', 'insufficient_evidence')
            ->assertJsonPath('answer_contract.confidence', 'low');
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
