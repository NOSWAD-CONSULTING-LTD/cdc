# CDC Provenance And Evidence Model

The provenance and evidence model explains how the graph shows where an assertion, value, mapping, or decision came from.

For beginners, provenance means "where did this information come from?" Evidence means "what supports this answer or decision?"

## Why This Model Exists

CDC manufacturing questions often need more than an answer. They need a traceable reason.

Example questions:

- Which reading triggered the alarm?
- Which alarm led to the deviation?
- Which batch record did QA review?
- Which evidence supports a CDE value?
- Which source supports a standards mapping?
- Can an agent explain why it gave an answer?

The provenance and evidence model helps avoid unsupported answers.

## Primary Audience

| Audience | Why They Use This Model |
| --- | --- |
| Quality stakeholders | To understand which evidence supports deviations, batch review, and QA disposition. |
| Regulatory / CMC stakeholders | To see how standards mappings, filing context, and validation evidence are supported. |
| Data governance leads | To check whether critical data has source, ownership, value, and provenance context. |
| AI/RAG engineers | To ground answers in graph paths, document evidence, and provenance statements. |
| Auditors and reviewers | To inspect whether an answer or decision has a traceable evidence chain. |

## Who Creates It In An Enterprise

The provenance and evidence model is usually created jointly by a **data governance lead**, **quality representative**, **regulatory/CMC representative**, and **data architect**.

For AI-assisted workflows, AI/RAG engineers and security/compliance stakeholders should also review it, because provenance determines what an agent can safely cite.

## How It Relates To Other Models

```text
Semantic data model
  explains what evidence relationships mean.

Logical data model
  defines required evidence entities and relationships.

Ontology
  formalizes evidence predicates and constraints.

Physical Neo4j graph
  stores the actual evidence paths.

RAG / agent model
  retrieves evidence and uses it to compose safe answers.
```

## Evidence Concepts

| Concept | Meaning |
| --- | --- |
| `SensorReading` | Time-stamped process or quality value. |
| `Alarm` | Event triggered by a reading or condition. |
| `Deviation` | Investigation into an alarm, excursion, or unexpected event. |
| `BatchRecord` | Execution and review summary for a run. |
| `QAReleaseDecision` | QA disposition decision reviewing batch evidence. |
| `EvidenceDocument` | Document-style evidence anchor for values, mappings, decisions, or filing context. |
| `ValidationEvidence` | Evidence supporting validation or regulatory context. |
| `ProvenanceStatement` | Source citation, retrieval context, confidence, or rationale for a standards mapping. |
| `AuditTrailEvent` | Data integrity or system event evidence. |
| `CDEValue` | Observed or representative value of a governed CDE. |

## Core Evidence Paths

### Reading To Deviation

```text
SensorReading RECORDED_BY Sensor
SensorReading DURING_RUN ManufacturingRun
Alarm TRIGGERED_BY SensorReading
Deviation INVESTIGATES Alarm
ManufacturingRun HAS_DEVIATION Deviation
```

This path explains why a deviation exists.

### Run To QA Disposition

```text
ManufacturingRun HAS_BATCH_RECORD BatchRecord
QAReleaseDecision REVIEWS BatchRecord
QAReleaseDecision RELEASES or REJECTS ManufacturingRun
```

This path explains how a run was dispositioned.

### CDE Value To Evidence

```text
CDEValue VALUE_OF CriticalDataElement
CDEValue OBSERVED_DURING ManufacturingRun
CDEValue DERIVED_FROM_READING SensorReading
EvidenceDocument EVIDENCES_CDE_VALUE CDEValue
```

This path explains how a value relates to a definition and run.

### Standard Mapping To Provenance

```text
StandardMapping MAPS_CDE CriticalDataElement
StandardMapping TO_STANDARD DataStandard
StandardMapping TO_REGULATORY_SECTION RegulatorySection
StandardMapping SUPPORTED_BY_PROVENANCE ProvenanceStatement
```

This path explains why a CDE is mapped to a standard or CMC section.

## Evidence Quality Questions

An evidence path is stronger when it can answer:

- What is the source system?
- What is the timestamp?
- What is the identifier?
- Which run, batch, material lot, or CDE does it relate to?
- Which document, audit event, or provenance statement supports it?
- Is the relationship direct evidence or contextual evidence?

## Agent Interpretation

An agent should use provenance and evidence to avoid guessing.

Good answer pattern:

```text
Answer
-> graph path used
-> relevant node IDs
-> evidence document or provenance source
-> caveat that this is demo/reference architecture data
```

Weak answer pattern:

```text
Answer
-> no source
-> no graph path
-> no IDs
-> no caveat
```

## Beginner Example

If a user asks, "Why was there a deviation?", the graph should not only return the deviation text. It should show:

```text
Deviation -> Alarm -> SensorReading -> Sensor -> ManufacturingRun
```

That path gives the answer a traceable evidence chain.

## Limitations

This demo includes simplified evidence and provenance. A real GxP system would require validated audit trails, controlled documents, electronic signatures, access controls, retention rules, and approved procedures.
