# CDC Integration Model

The integration model explains how data could flow between source systems, Neo4j, documents, and the Laravel agent in a production-inspired architecture.

It does not define a real production integration. It shows a reference pattern for architecture discussion.

## Why This Model Exists

The Neo4j graph is not intended to replace MES, LIMS, QMS, ERP, historians, document repositories, or regulatory systems.

Instead, Neo4j acts as a connected knowledge layer that links records from those systems so people and agents can ask traceability questions.

The integration model helps answer:

- Which systems might provide data?
- Which data objects move between systems?
- What should be loaded into Neo4j?
- Which data remains in source systems?
- How does the Laravel agent safely ask questions?

## Primary Audience

| Audience | Why They Use This Model |
| --- | --- |
| Integration architects | To understand how source systems could feed the graph. |
| Platform engineers | To plan ingestion, validation, upsert, and runtime patterns. |
| Data engineers | To understand which objects should be transformed before loading into Neo4j. |
| Security architects | To reason about read/write boundaries, agent access, and production RBAC expectations. |
| Application teams | To understand how the Laravel agent reads graph evidence without becoming a system of record. |

## Who Creates It In An Enterprise

The integration model is usually created by an **integration architect**, **solution architect**, or **platform architect**.

It should be reviewed with data engineers, security architects, infrastructure/platform teams, source-system owners, and application teams responsible for APIs, events, ETL/ELT, or graph loading.

## How It Relates To Other Models

```text
Canonical data model
  defines shared exchange objects.

Integration model
  explains how those objects move between source systems and the graph.

Physical graph model
  defines how connected instances are stored in Neo4j.

Agent/RAG model
  defines how approved questions retrieve graph evidence and documentation context.
```

## Source Systems

| Source System Type | Example Data |
| --- | --- |
| ERP / material management | Material master, supplier, lot, inventory status. |
| MES / EBR | Recipe execution, batch record, run context, operator review. |
| Historian / DCS / PLC | Time-series process values, equipment states, alarms. |
| PAT platform | NIR, soft sensor, blend uniformity, in-process predictions. |
| LIMS | Analytical methods, results, specifications, QC status. |
| QMS | Deviations, CAPA context, change controls, QA disposition. |
| Document management | SOPs, validation evidence, regulatory evidence, filing sections. |
| Data catalog / governance tool | CDE definitions, owners, stewards, data quality rules. |

## Reference Flow

```text
Source systems
  -> extract / event / API / file
  -> canonical data object
  -> validation and mapping
  -> Neo4j graph upsert
  -> graph integrity checks
  -> query packs / Laravel agent / Neo4j Browser
```

In this repository, Cypher seed files stand in for the extract and load process.

## Integration Patterns

| Pattern | Use |
| --- | --- |
| Batch load | Good for demo seed data, historical records, and periodic synchronization. |
| Event-driven updates | Good for run events, alarms, deviations, and status changes. |
| API pull | Good when source systems expose stable APIs. |
| Document indexing | Good for evidence documents and RAG retrieval context. |
| Graph enrichment | Good for adding semantic links, CDE mappings, provenance, and ontology alignment. |

## What Goes Into Neo4j

Neo4j should store connected context and identifiers, not necessarily every raw source value.

Good candidates:

- stable product, recipe, material, run, equipment, and CDE IDs;
- relationships between records;
- summary attributes needed for querying;
- evidence anchors and provenance references;
- source-system references back to authoritative systems.

Poor candidates:

- high-volume raw historian streams without aggregation;
- uncontrolled document blobs without metadata;
- secrets or credentials;
- source-system data copied without ownership, provenance, or lifecycle rules.

## Laravel Agent Integration

The Laravel agent demonstrates a constrained integration pattern:

```text
User question
-> approved question/template registry
-> read-mode Cypher query
-> Neo4j graph evidence
-> RAG manifest document context
-> deterministic answer / optional AI composition
```

The agent does not need direct write access to Neo4j. In a production design, a separate read-only user and stronger RBAC would be expected.

## Beginner Example

If a QMS deviation references an alarm from a historian, the integration model says both systems keep their source records. Neo4j stores the relationship:

```text
Deviation INVESTIGATES Alarm
Alarm TRIGGERED_BY SensorReading
SensorReading DURING_RUN ManufacturingRun
```

That relationship makes impact assessment possible without making Neo4j the QMS or historian.

## Limitations

This model does not implement real connectors, message queues, source-system APIs, data contracts, or production security. It is an architecture pattern for discussion.
