# Contributing

Thank you for your interest in improving this reference architecture.

This repository is maintained as a public demonstration of CDC manufacturing knowledge graph, ontology, CDE, CMC/QMS, and AI-readiness patterns. Contributions should preserve that purpose.

## Contribution Principles

- Keep the model production-inspired but safe as demo data.
- Do not add real product names, real batch data, real supplier data, real regulatory filings, or client-confidential information.
- Use stable IDs for major graph nodes.
- Use idempotent Cypher with `MERGE` for seed data.
- Keep terminology aligned with `docs/domain-glossary.md`.
- Keep documentation, ontology files, RAG manifest entries, and tests up to date when changing model concepts.
- Preserve attribution to NOSWAD CONSULTING LTD.

## Pull Request Checklist

Before opening a pull request, run:

```bash
scripts/refresh-and-test.sh
```

For Laravel-only changes, also run:

```bash
cd laravel-agent
php85 vendor/bin/pint --dirty --format agent
php85 artisan test --compact
```

Include a short summary of:

- what changed;
- which files or graph areas were affected;
- how you tested it;
- any limitations or follow-up work.

## Data Safety

Do not submit:

- real patient, subject, batch, supplier, equipment, or personnel data;
- real regulatory filing content;
- proprietary client models or documents;
- secrets, passwords, tokens, API keys, or private connection strings.

## Commercial Attribution

This project requires attribution to NOSWAD CONSULTING LTD. See `LICENSE`, `NOTICE`, and `CITATION.cff`.
