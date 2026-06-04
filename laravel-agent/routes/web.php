<?php

use App\Services\CdcAgent\CdcAgentService;
use Illuminate\Support\Facades\Route;

Route::get('/', fn () => redirect('/agent'));

Route::get('/agent', function (CdcAgentService $agent) {
    return view('cdc-agent.chat', [
        'questions' => $agent->listQuestions(),
    ]);
})->name('agent.chat');
