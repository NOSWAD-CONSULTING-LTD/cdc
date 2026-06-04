<?php

namespace Tests\Feature;

use Tests\TestCase;

class CdcAgentEvaluateCommandTest extends TestCase
{
    public function test_it_lists_available_cdc_agent_questions(): void
    {
        $this->artisan('cdc-agent:evaluate', ['--list' => true])
            ->expectsOutputToContain('q001_material_genealogy')
            ->expectsOutputToContain('q008_process_path')
            ->assertSuccessful();
    }

    public function test_it_fails_for_an_unknown_question_id(): void
    {
        $this->artisan('cdc-agent:evaluate', ['--question' => 'missing-question'])
            ->expectsOutputToContain('No question found for missing-question.')
            ->assertFailed();
    }
}
