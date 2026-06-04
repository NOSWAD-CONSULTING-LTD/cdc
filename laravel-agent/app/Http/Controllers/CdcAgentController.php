<?php

namespace App\Http\Controllers;

use App\Http\Requests\CdcAgentAskRequest;
use App\Services\CdcAgent\CdcAgentService;
use Illuminate\Http\JsonResponse;
use RuntimeException;

class CdcAgentController extends Controller
{
    public function ask(CdcAgentAskRequest $request, CdcAgentService $agent): JsonResponse
    {
        $validated = $request->validated();

        try {
            $result = $agent->ask(
                questionText: $validated['question'],
                questionId: $validated['question_id'] ?? null,
            );
        } catch (RuntimeException $exception) {
            return response()->json([
                'message' => $exception->getMessage(),
            ], 404);
        }

        return response()->json($result);
    }
}
