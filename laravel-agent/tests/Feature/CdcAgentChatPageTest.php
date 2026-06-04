<?php

namespace Tests\Feature;

use Tests\TestCase;

class CdcAgentChatPageTest extends TestCase
{
    public function test_it_shows_the_cdc_agent_chat_page(): void
    {
        $this->get('/agent')
            ->assertOk()
            ->assertSee('CDC Graph Agent')
            ->assertSee('q013_relationship_definition')
            ->assertSee('/api/agent/ask');
    }
}
