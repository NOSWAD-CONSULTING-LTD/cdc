<?php

return [
    'ai' => [
        'enabled' => env('CDC_AGENT_AI_ENABLED', false),
        'provider' => env('CDC_AGENT_AI_PROVIDER', config('ai.default', 'openai')),
        'model' => env('CDC_AGENT_AI_MODEL'),
        'timeout' => env('CDC_AGENT_AI_TIMEOUT', 30),
    ],
];
