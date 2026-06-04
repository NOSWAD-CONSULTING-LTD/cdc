<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="utf-8">
    <meta name="viewport" content="width=device-width, initial-scale=1">
    <title>CDC Graph Agent</title>
    <style>
        :root {
            color-scheme: light;
            --bg: #f7f8fa;
            --panel: #ffffff;
            --ink: #17202a;
            --muted: #5f6b7a;
            --line: #d9dee6;
            --accent: #1f7a5c;
            --accent-dark: #15563f;
            --warn: #8a5b00;
            --code: #111827;
        }

        * {
            box-sizing: border-box;
        }

        body {
            margin: 0;
            background: var(--bg);
            color: var(--ink);
            font-family: ui-sans-serif, system-ui, -apple-system, BlinkMacSystemFont, "Segoe UI", sans-serif;
            line-height: 1.45;
        }

        .shell {
            display: grid;
            grid-template-columns: minmax(260px, 340px) minmax(0, 1fr);
            min-height: 100vh;
        }

        aside {
            border-right: 1px solid var(--line);
            background: #eef2f5;
            padding: 20px;
        }

        main {
            padding: 24px;
        }

        h1 {
            margin: 0 0 8px;
            font-size: 24px;
            letter-spacing: 0;
        }

        h2 {
            margin: 0 0 12px;
            font-size: 17px;
            letter-spacing: 0;
        }

        p {
            margin: 0 0 16px;
            color: var(--muted);
        }

        label {
            display: block;
            margin-bottom: 8px;
            font-weight: 650;
        }

        select,
        textarea,
        button {
            width: 100%;
            border: 1px solid var(--line);
            border-radius: 6px;
            font: inherit;
        }

        select,
        textarea {
            background: var(--panel);
            color: var(--ink);
            padding: 10px 12px;
        }

        textarea {
            min-height: 96px;
            resize: vertical;
        }

        button {
            margin-top: 12px;
            border-color: var(--accent);
            background: var(--accent);
            color: white;
            padding: 11px 14px;
            font-weight: 700;
            cursor: pointer;
        }

        button:hover,
        button:focus {
            background: var(--accent-dark);
        }

        .panel {
            background: var(--panel);
            border: 1px solid var(--line);
            border-radius: 8px;
            padding: 18px;
            margin-bottom: 16px;
        }

        .question-list {
            display: grid;
            gap: 8px;
            margin-top: 18px;
        }

        .question-button {
            width: 100%;
            text-align: left;
            border: 1px solid var(--line);
            border-radius: 6px;
            background: white;
            color: var(--ink);
            padding: 10px;
            font-weight: 600;
        }

        .question-button span {
            display: block;
            margin-top: 2px;
            color: var(--muted);
            font-size: 13px;
            font-weight: 500;
            overflow-wrap: anywhere;
        }

        .grid {
            display: grid;
            grid-template-columns: repeat(2, minmax(0, 1fr));
            gap: 16px;
        }

        .status {
            display: inline-flex;
            align-items: center;
            gap: 8px;
            border: 1px solid var(--line);
            border-radius: 999px;
            padding: 5px 10px;
            color: var(--muted);
            font-size: 13px;
            font-weight: 700;
        }

        pre {
            max-height: 360px;
            overflow: auto;
            margin: 0;
            background: var(--code);
            color: #f9fafb;
            border-radius: 6px;
            padding: 14px;
            font-size: 13px;
            white-space: pre-wrap;
            overflow-wrap: anywhere;
        }

        .answer {
            white-space: pre-wrap;
        }

        .error {
            color: var(--warn);
            font-weight: 700;
        }

        [hidden] {
            display: none;
        }

        @media (max-width: 860px) {
            .shell,
            .grid {
                grid-template-columns: 1fr;
            }

            aside {
                border-right: 0;
                border-bottom: 1px solid var(--line);
            }
        }
    </style>
</head>
<body>
    <div class="shell">
        <aside>
            <h1>CDC Graph Agent</h1>
            <p>Ask controlled questions against the Neo4j CDC knowledge graph. Answers are grounded in approved Cypher templates and retrieved project documents.</p>

            <label for="question">Question</label>
            <textarea id="question">What does REJECTS mean?</textarea>

            <label for="question-id" style="margin-top: 12px;">Approved question</label>
            <select id="question-id">
                @foreach ($questions as $question)
                    <option value="{{ $question['id'] }}">{{ $question['id'] }}</option>
                @endforeach
            </select>

            <button id="ask" type="button">Ask Agent</button>

            <div class="question-list" aria-label="Starter questions">
                @foreach ($questions as $question)
                    <button class="question-button" type="button" data-question="{{ $question['question'] }}" data-id="{{ $question['id'] }}">
                        {{ $question['id'] }}
                        <span>{{ $question['question'] }}</span>
                    </button>
                @endforeach
            </div>
        </aside>

        <main>
            <section class="panel">
                <h2>Answer</h2>
                <p id="meta">Endpoint: /api/agent/ask</p>
                <div id="error" class="error" hidden></div>
                <div id="answer" class="answer">Choose a starter question or submit your own wording.</div>
            </section>

            <div class="grid">
                <section class="panel">
                    <h2>Answer Contract</h2>
                    <p><span id="status" class="status">waiting</span></p>
                    <pre id="contract">{}</pre>
                </section>

                <section class="panel">
                    <h2>Graph Evidence</h2>
                    <pre id="evidence">[]</pre>
                </section>
            </div>

            <section class="panel">
                <h2>Retrieved Documents</h2>
                <pre id="documents">[]</pre>
            </section>
        </main>
    </div>

    <script>
        const askButton = document.querySelector('#ask');
        const question = document.querySelector('#question');
        const questionId = document.querySelector('#question-id');
        const answer = document.querySelector('#answer');
        const error = document.querySelector('#error');
        const meta = document.querySelector('#meta');
        const status = document.querySelector('#status');
        const contract = document.querySelector('#contract');
        const evidence = document.querySelector('#evidence');
        const documents = document.querySelector('#documents');

        document.querySelectorAll('.question-button').forEach((button) => {
            button.addEventListener('click', () => {
                question.value = button.dataset.question;
                questionId.value = button.dataset.id;
                ask();
            });
        });

        askButton.addEventListener('click', ask);

        async function ask() {
            askButton.disabled = true;
            askButton.textContent = 'Asking...';
            error.hidden = true;

            try {
                const response = await fetch('/api/agent/ask', {
                    method: 'POST',
                    headers: {
                        'Content-Type': 'application/json',
                        'Accept': 'application/json',
                    },
                    body: JSON.stringify({
                        question: question.value,
                        question_id: questionId.value,
                    }),
                });

                const data = await response.json();

                if (!response.ok) {
                    throw new Error(data.message || 'Agent request failed.');
                }

                meta.textContent = `${data.ai_mode} · ${data.template_id} · ${data.evidence.length} graph rows`;
                status.textContent = `${data.answer_contract.status} · ${data.answer_contract.confidence}`;
                answer.textContent = data.answer;
                contract.textContent = JSON.stringify(data.answer_contract, null, 2);
                evidence.textContent = JSON.stringify(data.evidence, null, 2);
                documents.textContent = JSON.stringify(data.documents, null, 2);
            } catch (exception) {
                error.hidden = false;
                error.textContent = exception.message;
            } finally {
                askButton.disabled = false;
                askButton.textContent = 'Ask Agent';
            }
        }
    </script>
</body>
</html>
