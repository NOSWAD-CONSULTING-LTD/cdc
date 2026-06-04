# Complete AI-Ready CDC Backlog Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Complete remaining CDC knowledge graph improvements, refresh the graph, audit the result, and add a beginner handbook.

**Architecture:** Keep the Neo4j graph as the executable source of truth, with idempotent Cypher seeds and validation checks. Keep documentation, ontology artifacts, RAG manifest records, and deterministic agent questions aligned to the graph.

**Tech Stack:** Neo4j 5 Cypher, Docker Compose, Markdown/HTML docs, JSON/JSONL manifests, Laravel 13 / PHP 8.5 agent CLI/API.

---

### Task 1: Extend Graph Model

**Files:**
- Modify: `cypher/01_constraints.cypher`
- Modify: `cypher/03_seed_manufacturing_run.cypher`
- Modify: `cypher/09_seed_ai_readiness_enrichment.cypher`

- [x] Add unique constraints for `EvidenceDocument`, `CDEDomain`, `CriticalityLevel`, `DecisionStatus`, `DeviationSeverity`, `RunStatus`, and `RelationshipDefinition`.
- [x] Seed evidence documents linked to CDE values, standard mappings, CMC sections, validation evidence, and regulatory filing context.
- [x] Seed controlled vocabulary nodes and connect existing CDEs, runs, deviations, and QA decisions to vocabulary nodes.
- [x] Add a second demo run with a quarantine/reject-style disposition and an explicit `REJECTS` relationship so browser queries have both relationship types available.

### Task 2: Add Machine-Readable Ontology Mapping

**Files:**
- Create: `docs/ontology/relationship-map.json`
- Modify: `docs/ontology/cdc-ontology.md`
- Modify: `docs/ontology/cdc-relationship-matrix.md`

- [x] Create a JSON relationship map with Neo4j relationship type, ontology predicate, subject labels, object labels, cardinality note, and description.
- [x] Cross-reference the map from the ontology guide and relationship matrix.
- [x] Seed `RelationshipDefinition` nodes from the same conceptual set.

### Task 3: Add Agent Coverage

**Files:**
- Modify: `laravel-agent/resources/cdc-agent/query_templates.json`
- Modify: `laravel-agent/resources/cdc-agent/questions.json`
- Modify: `laravel-agent/resources/cdc-agent/expected_answers.json`

- [x] Add approved templates for evidence documents, controlled vocabularies, relationship definitions, and run disposition comparison.
- [x] Add deterministic agent questions and expected answer checks.

### Task 4: Add Testing Script

**Files:**
- Create: `scripts/refresh-and-test.sh`
- Modify: `README.md`

- [x] Add a shell script that performs full graph refresh, applies security user setup, runs Neo4j validation checks, Laravel formatting/tests/agent checks, JSON validation, RAG manifest validation, and Markdown link checks.
- [x] Document when and how to use the script.

### Task 5: Add Beginner Documentation

**Files:**
- Create: `docs/beginner-handbook.md`
- Create: `docs/how-to-read-graph-answers.md`
- Create: `docs/ai-readiness-evidence-a4.html`
- Modify: `README.md`
- Modify: `docs/domain-glossary.md`
- Modify: `docs/rag-manifest.jsonl`

- [x] Explain CDC pharmaceutical domain basics and what the demo models.
- [x] Explain graph, knowledge graph, Cypher, ontology, semantics, conceptual/logical/physical models, AI-ready data, RAG, JSONL manifests, and agent testing for beginners.
- [x] Add a practical answer-interpretation guide.
- [x] Add a printable A4 AI-readiness/evidence diagram.
- [x] Update glossary and RAG manifest with new documents and terms.

### Task 6: Final Refresh And Audit

**Files:**
- Modify: `docs/improvement-backlog.md`
- Create: `docs/final-audit.md`
- Modify: `README.md`

- [x] Run a full graph refresh.
- [x] Run AI-readiness checks, graph integrity checks, Laravel tests, Laravel agent checks, JSON validation, RAG manifest validation, and Markdown link validation.
- [x] Capture graph counts and audit findings.
- [x] Mark improvements `IMP-009` through `IMP-015` complete with implementation notes.
