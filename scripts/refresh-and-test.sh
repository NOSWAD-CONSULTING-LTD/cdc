#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$ROOT_DIR"

ADMIN_USER="${NEO4J_ADMIN_USERNAME:-neo4j}"
ADMIN_PASSWORD="${NEO4J_ADMIN_PASSWORD:-cdc-demo-password}"
PHP_BIN="${PHP_BIN:-}"

if [[ -z "$PHP_BIN" ]]; then
  if command -v php85 >/dev/null 2>&1; then
    PHP_BIN="$(command -v php85)"
  elif command -v php8.5 >/dev/null 2>&1; then
    PHP_BIN="$(command -v php8.5)"
  else
    PHP_BIN="$(command -v php)"
  fi
fi

run_cypher_file() {
  local file="$1"
  echo "==> Running ${file}"
  docker compose exec -T neo4j cypher-shell -u "$ADMIN_USER" -p "$ADMIN_PASSWORD" -f "/${file}"
}

echo "==> Checking Neo4j container"
docker compose ps neo4j

echo "==> Clearing graph data"
docker compose exec -T neo4j cypher-shell -u "$ADMIN_USER" -p "$ADMIN_PASSWORD" "MATCH (n) DETACH DELETE n;"

run_cypher_file "cypher/01_constraints.cypher"
run_cypher_file "cypher/02_seed_reference_data.cypher"
run_cypher_file "cypher/03_seed_manufacturing_run.cypher"
run_cypher_file "cypher/05_seed_cmc_qms_extension.cypher"
run_cypher_file "cypher/07_seed_end_to_end_cde_model.cypher"
run_cypher_file "cypher/09_seed_ai_readiness_enrichment.cypher"
run_cypher_file "cypher/12_security_agent_user.cypher"

echo "==> Running Neo4j AI-readiness checks"
docker compose exec -T neo4j cypher-shell -u "$ADMIN_USER" -p "$ADMIN_PASSWORD" --format plain -f /cypher/10_ai_readiness_checks.cypher

echo "==> Running Neo4j graph integrity checks"
docker compose exec -T neo4j cypher-shell -u "$ADMIN_USER" -p "$ADMIN_PASSWORD" --format plain -f /cypher/11_graph_integrity_checks.cypher

echo "==> Validating agent JSON"
python3 -m json.tool laravel-agent/resources/cdc-agent/query_templates.json >/dev/null
python3 -m json.tool laravel-agent/resources/cdc-agent/questions.json >/dev/null
python3 -m json.tool laravel-agent/resources/cdc-agent/expected_answers.json >/dev/null
python3 -m json.tool docs/ontology/relationship-map.json >/dev/null

echo "==> Validating RAG manifest"
python3 - <<'PY'
import json
from pathlib import Path

required = {
    "chunk_id",
    "path",
    "title",
    "content_type",
    "summary",
    "retrieval_text",
    "answers",
    "tags",
    "source_priority",
}

count = 0
for count, line in enumerate(Path("docs/rag-manifest.jsonl").read_text().splitlines(), 1):
    item = json.loads(line)
    missing = required - set(item)
    if missing:
        raise SystemExit(f"line {count} missing fields: {sorted(missing)}")
    if not Path(item["path"]).exists():
        raise SystemExit(f"line {count} missing path: {item['path']}")

print(f"validated {count} RAG manifest records")
PY

echo "==> Checking Markdown links"
python3 - <<'PY'
import re
from pathlib import Path

root = Path(".")
missing = []
pattern = re.compile(r"\[[^\]]+\]\(([^)]+)\)")

paths = [root / "README.md"]
paths.extend(root.glob("docs/**/*.md"))
paths.extend(root.glob("laravel-agent/**/*.md"))

for path in paths:
    if "vendor" in path.parts:
        continue
    text = path.read_text(errors="ignore")
    for match in pattern.finditer(text):
        target = match.group(1).split("#", 1)[0]
        if not target or re.match(r"^[a-z]+:", target) or target.startswith("mailto:"):
            continue
        if not (path.parent / target).resolve().exists():
            missing.append((str(path), target))

if missing:
    for source, target in missing:
        print(f"{source}: missing {target}")
    raise SystemExit(1)

print("markdown links ok")
PY

echo "==> Running Laravel checks"
(
  cd laravel-agent
  "$PHP_BIN" -v
  "$PHP_BIN" vendor/bin/pint --dirty --format agent
  "$PHP_BIN" artisan test --compact
  "$PHP_BIN" artisan cdc-agent:evaluate
)

echo "==> Graph counts"
docker compose exec -T neo4j cypher-shell -u "$ADMIN_USER" -p "$ADMIN_PASSWORD" --format plain \
  "MATCH (n) RETURN labels(n)[0] AS primaryLabel, count(*) AS count ORDER BY primaryLabel;"

echo "==> Refresh and test completed"
