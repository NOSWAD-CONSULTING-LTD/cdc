# CDC Knowledge Graph Improvement Backlog

This backlog captures sensible next improvements for the CDC Neo4j demo and AI-agent harness. It is not a defect list; it is a controlled place to track enhancements without destabilising the current reference architecture.

Status values:

- `Proposed`: identified but not started.
- `Ready`: clear enough to implement.
- `In progress`: actively being changed.
- `Done`: implemented and verified.

## Backlog

| ID | Status | Priority | Area | Improvement | Why It Matters | Implementation Notes |
| --- | --- | --- | --- | --- | --- | --- |
| IMP-001 | Done | High | Agent | Build a small runner for approved CDC graph questions and templates. | Proves the AI harness can execute repeatable tests rather than remaining static documentation. | Consolidated into Laravel as `php85 artisan cdc-agent:evaluate` plus `POST /api/agent/ask`. |
| IMP-002 | Done | High | Agent safety | Add a formal approved-template registry in JSON or YAML. | Easier for a Laravel agent to map `template_id` to query text without parsing comments from a `.cypher` file. | Implemented in `laravel-agent/resources/cdc-agent/` with `template_id`, `description`, `params`, `cypher`, and `result_contract`. |
| IMP-003 | Done | High | Laravel | Scaffold a Laravel console command for agent evaluation. | Gives a realistic application path for testing Laravel AI SDK integration. | Implemented in `laravel-agent` as `php85 artisan cdc-agent:evaluate`; Laravel Boost installed. |
| IMP-004 | Done | High | AI grounding | Add answer-evaluation scoring. | Lets us measure whether answers include required evidence and avoid prohibited claims. | Implemented in Laravel with `must_include` and `must_not_claim` checks from `laravel-agent/resources/cdc-agent/expected_answers.json`. |
| IMP-005 | Done | Medium | RAG | Add document chunk excerpts or embeddings-ready content. | Current `rag-manifest.jsonl` pointed to documents, but did not yet contain retrieval text. | Added `summary`, `retrieval_text`, and `source_priority` fields plus `docs/rag-manifest-readme.md`. |
| IMP-006 | Done | Medium | Security | Add read-only Neo4j credentials for agent use. | The agent should not use the admin demo account. | Implemented `cypher/12_security_agent_user.cypher` and switched the Laravel agent to `cdc_agent_reader`; Neo4j Community limitation documented. |
| IMP-007 | Done | Medium | Graph validation | Add more graph integrity checks beyond AI readiness. | Helps catch ontology drift, missing relationships, and stale docs after model changes. | Implemented as `cypher/11_graph_integrity_checks.cypher`; all checks pass. |
| IMP-008 | Done | Medium | CDE values | Add more representative `CDEValue` records across crystallisation, drying, milling, and coating. | Current values prove the pattern, but more values would make end-to-end AI questions richer. | Added 25 simulated series observations and an approved `cde_value_series` agent template. |
| IMP-009 | Done | Medium | Evidence | Add evidence documents as explicit graph nodes for CDE provenance. | Improves traceability from answer to source and supports stronger regulatory-evidence reasoning. | Added `EvidenceDocument` nodes linked to `CDEValue`, `StandardMapping`, `RegulatorySection`, `BatchRecord`, `QAReleaseDecision`, `ManufacturingRun`, `ValidationEvidence`, and `RegulatoryFiling`. |
| IMP-010 | Done | Medium | Ontology | Align Neo4j relationship names and ontology predicates in one machine-readable mapping. | Reduces drift between Cypher, Turtle, SHACL, and docs. | Added `docs/ontology/relationship-map.json` and seeded `RelationshipDefinition` nodes. |
| IMP-011 | Done | Medium | Data quality | Model controlled vocabularies as graph nodes rather than only properties/docs. | Makes reference data queryable and governable. | Added `CDEDomain`, `CriticalityLevel`, `DecisionStatus`, `DeviationSeverity`, and `RunStatus` nodes with graph links. |
| IMP-012 | Done | Medium | Visuals | Add a printable A4 AI-readiness/evidence diagram. | Useful for explaining agent grounding to non-technical stakeholders. | Added `docs/ai-readiness-evidence-a4.html`. |
| IMP-013 | Done | Low | Testing | Add shell-based smoke tests for all seed and query files. | Makes refresh verification repeatable. | Added `scripts/refresh-and-test.sh`; final run passed. |
| IMP-014 | Done | Low | Data realism | Add a second manufacturing run with a different disposition. | Improves agent tests for comparing released, quarantined, and rejected outcomes. | Added `RUN-CDC-2026-06-02-002` with `REJECTS` disposition, deviation, alarm, readings, and evidence document. |
| IMP-015 | Done | Low | Documentation | Add a one-page "How to interpret graph answers" guide. | Helps users understand paths, labels, evidence, and limitations. | Added `docs/how-to-read-graph-answers.md` and a broader `docs/beginner-handbook.md`. |

## Recently Completed Improvements

| ID | Status | Area | Improvement |
| --- | --- | --- | --- |
| DONE-001 | Done | AI readiness | Added value domains, units, allowed values, CDE versions, approvals, CDE values, and provenance statements. |
| DONE-002 | Done | Validation | Added `cypher/10_ai_readiness_checks.cypher`. |
| DONE-003 | Done | Documentation | Updated README, glossary, ontology docs, CDE catalog, and RAG manifest. |
| DONE-004 | Done | Agent | Added constrained Laravel agent execution using approved templates and deterministic scoring. |
| DONE-005 | Done | Agent | Added machine-readable approved template registry and deterministic Laravel evaluation runner. |
| DONE-006 | Done | AI grounding | Added deterministic answer scoring for required evidence and prohibited claims. |
| DONE-007 | Done | Laravel | Added PHP 8.5 Laravel 13 app with `cdc-agent:evaluate`, `POST /api/agent/ask`, feature tests, and Laravel Boost. |
| DONE-008 | Done | Graph validation | Added structural integrity checks and anchored reference catalog nodes to remove orphan nodes. |
| DONE-009 | Done | Security | Added separate Neo4j agent credentials and configurable Laravel agent authentication. |
| DONE-010 | Done | RAG | Enriched the RAG manifest with retrieval-ready summaries, retrieval text, and schema documentation. |
| DONE-011 | Done | CDE values | Added simulated CDE value series for crystallisation, drying, milling, and coating plus a deterministic agent regression question. |
| DONE-012 | Done | Evidence | Added evidence-document graph nodes and agent evidence-document lookup. |
| DONE-013 | Done | Ontology | Added machine-readable relationship map and relationship-definition graph nodes. |
| DONE-014 | Done | Reference data | Added controlled vocabulary graph nodes for CDEs, runs, decisions, and deviations. |
| DONE-015 | Done | Visuals | Added printable AI-readiness evidence diagram. |
| DONE-016 | Done | Testing | Added full refresh-and-test script. |
| DONE-017 | Done | Data realism | Added second rejected/quarantined manufacturing run. |
| DONE-018 | Done | Documentation | Added beginner handbook, graph-answer guide, and final audit. |
