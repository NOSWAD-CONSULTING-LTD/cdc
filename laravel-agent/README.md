# CDC Laravel Agent

This Laravel app is the CDC Neo4j agent implementation.

It uses PHP 8.5, Laravel 13, and Laravel Boost. The agent intentionally uses approved Cypher templates from `resources/cdc-agent/query_templates.json` rather than generating arbitrary Cypher.

The agent has two entry points:

- CLI: `php85 artisan cdc-agent:evaluate`
- Browser UI: `/agent`
- HTTP API: `POST /api/agent/ask`

## Run With Laravel Herd

This project is designed to work from a [Laravel Herd](https://herd.laravel.com) workspace on macOS.

The repository root is expected to be inside Herd, for example:

```text
/Users/simondawson/Herd/cdc
```

The Laravel app lives one level down:

```text
/Users/simondawson/Herd/cdc/laravel-agent
```

### Option 1: Herd Parked Site

If Herd is serving the `Herd` folder, the app should be available using a Herd local domain based on the folder name:

```text
http://laravel-agent.test/agent
```

If that URL does not resolve, open Herd and check that:

- the `Herd` directory is parked;
- the `laravel-agent` folder is visible as a site;
- the site is using PHP 8.5;
- Docker Desktop is running;
- the parent Neo4j container is running with `docker compose up -d` from the repository root.

### Option 2: Herd PHP CLI

From the Laravel app directory:

```bash
cd /Users/simondawson/Herd/cdc/laravel-agent
php85 artisan serve
```

Then open:

```text
http://localhost:8000/agent
```

The API endpoint will be:

```text
http://localhost:8000/api/agent/ask
```

## Run The CLI Agent

From this directory:

```bash
php85 artisan cdc-agent:evaluate
```

List available questions:

```bash
php85 artisan cdc-agent:evaluate --list
```

Run one question and show the deterministic evidence answer:

```bash
php85 artisan cdc-agent:evaluate --question=q005_cde_value_evidence --show-answer
```

Run the CDE value-series example:

```bash
php85 artisan cdc-agent:evaluate --question=q009_cde_value_series --show-answer
```

## API

If using Herd parked sites:

```bash
curl -X POST http://laravel-agent.test/api/agent/ask \
  -H "Content-Type: application/json" \
  -d '{"question":"What does REJECTS mean?","question_id":"q013_relationship_definition"}'
```

If using `php85 artisan serve`:

```bash
curl -X POST http://localhost:8000/api/agent/ask \
  -H "Content-Type: application/json" \
  -d '{"question":"What does REJECTS mean?","question_id":"q013_relationship_definition"}'
```

The response includes:

- `answer`: deterministic evidence-grounded answer text.
- `template_id`: approved Cypher template used.
- `evidence`: Neo4j rows returned by the template.
- `documents`: relevant RAG manifest records.
- `evaluation`: required/prohibited answer checks.
- `warnings`: demo and safety limitations.

## Requirements

- Neo4j container running from the parent project.
- Docker Compose available from the parent project root.
- PHP 8.5.
- Agent Neo4j user created by the parent project's `cypher/12_security_agent_user.cypher` file.

If your shell default `php` is older than 8.5, use Herd's `php85` binary or set `PHP_BIN` when running the parent refresh script:

```bash
PHP_BIN="$(which php85)" ../scripts/refresh-and-test.sh
```

The agent registry lives in:

- `resources/cdc-agent/questions.json`
- `resources/cdc-agent/expected_answers.json`
- `resources/cdc-agent/query_templates.json`

The command defaults to:

```text
CDC_AGENT_NEO4J_USERNAME=cdc_agent_reader
CDC_AGENT_NEO4J_PASSWORD=cdc-agent-reader-password
```

These values can be overridden in `.env`.

## Boost

Laravel Boost is installed for this app:

```bash
php85 artisan boost:list-skills
```

Boost generated:

- `AGENTS.md`
- `boost.json`
- `.codex/config.toml`
- `.agents/skills/laravel-best-practices/SKILL.md`

## Test

```bash
php85 vendor/bin/pint --dirty --format agent
php85 artisan test --compact
```
