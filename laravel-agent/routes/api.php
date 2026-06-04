<?php

use App\Http\Controllers\CdcAgentController;
use Illuminate\Support\Facades\Route;

Route::post('/agent/ask', [CdcAgentController::class, 'ask'])
    ->name('agent.ask');
