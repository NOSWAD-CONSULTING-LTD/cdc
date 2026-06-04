# How To Read Graph Answers

This guide explains how to interpret answers from Neo4j Browser, Cypher queries, or the Laravel agent CLI/API.

## 1. Start With The Question Type

Most questions fall into one of these patterns:

| Question Type | What To Look For |
| --- | --- |
| Genealogy | `ManufacturingRun -> MaterialLot -> Material -> Supplier` |
| Process | `Recipe -> ProcessStep -> Equipment -> Sensor` |
| Quality event | `ManufacturingRun -> Deviation -> Alarm -> SensorReading` |
| QA disposition | `QAReleaseDecision -> RELEASES/REJECTS -> ManufacturingRun` |
| CDE governance | `CriticalDataElement -> DataOwner/DataSteward/DataQualityRule/DataStandard` |
| CDE evidence | `CDEValue -> CriticalDataElement -> ValueDomain -> UnitOfMeasure` |
| Regulatory evidence | `Product -> RegulatoryFiling -> ValidationEvidence/CMCPackage` |

## 2. Read Direction, But Do Not Over-Interpret It

Neo4j relationships have direction:

```text
(ManufacturingRun)-[:CONSUMES]->(MaterialLot)
```

This reads naturally as "the run consumes the lot." Direction helps make queries readable, but the business meaning is in the relationship type and surrounding nodes.

## 3. Separate Definitions From Events

Definitions describe what something is.

Examples:

- `Product`
- `Recipe`
- `Material`
- `Sensor`
- `CriticalDataElement`
- `ValueDomain`

Events and evidence describe what happened.

Examples:

- `ManufacturingRun`
- `SensorReading`
- `Alarm`
- `Deviation`
- `BatchRecord`
- `QAReleaseDecision`
- `CDEValue`

Do not treat a `CriticalDataElement` as a measured result. The measured or observed value is a `CDEValue` or `SensorReading`.

## 4. Check The Evidence Chain

For AI-ready answers, look for an evidence chain.

A strong CDE answer should usually show:

```text
CDEValue
-> CriticalDataElement
-> ValueDomain
-> UnitOfMeasure
-> ManufacturingRun
-> EvidenceDocument or SensorReading
```

A strong regulatory answer should usually show:

```text
Product
-> RegulatoryFiling
-> CMCPackage
-> RegulatorySection
-> StandardMapping
-> ProvenanceStatement or EvidenceDocument
```

## 5. Understand Released Versus Rejected Runs

The demo has two run outcomes:

```text
(QAReleaseDecision)-[:RELEASES]->(RUN-CDC-2026-06-01-001)
(QAReleaseDecision)-[:REJECTS]->(RUN-CDC-2026-06-02-002)
```

Released means the demo QA decision accepted the run after review.

Rejected means the demo QA decision did not release the run and the material is treated as quarantined/rejected in the example.

## 6. Watch For Demo Language

Many records are intentionally marked as demo/reference architecture data. If an answer says "validated," "approved product," or "real regulatory filing," that is too strong.

Correct wording:

```text
This is fictional demo data from the CDC reference architecture.
```

Incorrect wording:

```text
This proves the batch is commercially approved.
```

## 7. How To Read Agent Answers

The agent harness output includes:

- question ID;
- approved template ID;
- number of rows returned;
- evidence rows;
- a demo-data note.

The key checks are:

- Did it use the expected approved template?
- Did it return evidence from Neo4j?
- Did it include required identifiers?
- Did it avoid claims that are not in the graph?

## 8. Good Follow-Up Questions

After reading an answer, ask:

- What node provides the evidence?
- Is this definition data or execution data?
- Is the value linked to a unit and value domain?
- Is the run released or rejected?
- Is there a deviation or alarm path?
- Is the standards mapping supported by provenance?
- Is this demo data being described as demo data?
