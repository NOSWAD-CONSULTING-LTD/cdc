# CDC Information Architecture Model

The information architecture model explains how information is organized, owned, governed, and used across the CDC manufacturing knowledge graph.

It is broader than a data model. It asks: who owns the information, where does it come from, what is it used for, and how should people navigate it?

## Why This Model Exists

The graph connects manufacturing, quality, regulatory, engineering, and data governance information. Without an information architecture model, the graph can become a technical diagram without clear ownership or purpose.

This model helps answer:

- Which information domains exist?
- Which teams own or steward the information?
- Which systems are authoritative?
- Which information supports operations, quality, CMC, and AI-assisted answers?
- Which documents should people read first?

## Primary Audience

| Audience | Why They Use This Model |
| --- | --- |
| Information architects | To organize the domain into understandable information areas and navigation paths. |
| Data governance leads | To identify ownership, stewardship, lifecycle, and source-system boundaries. |
| Quality and regulatory stakeholders | To see how manufacturing, CMC, QMS, evidence, and data governance connect. |
| Enterprise architects | To connect business capability, data domains, systems, and governance concerns. |
| Workshop participants | To understand where to start and how to move through the reference architecture. |

## Who Creates It In An Enterprise

The information architecture model is usually created by an **information architect**, **enterprise architect**, or **data governance lead**.

It should be shaped with business data owners, quality/regulatory representatives, manufacturing SMEs, system owners, and architecture stakeholders.

## How It Relates To Other Models

```text
Semantic data model
  explains meaning.

Information architecture model
  explains organization, ownership, navigation, governance, and use.

Integration model
  explains how information moves between systems.

Provenance/evidence model
  explains how information is supported and trusted.
```

## Information Domains

| Domain | Purpose | Example Concepts |
| --- | --- | --- |
| Product knowledge | Defines what is being made. | `Product`, `Formulation`, `Recipe`, `CMCPackage` |
| Process knowledge | Defines how it is made. | `ProcessStep`, `UnitOperation`, `CPP`, `ControlStrategy` |
| Material knowledge | Defines what materials and lots are used. | `Material`, `MaterialLot`, `Supplier`, `CMA` |
| Asset knowledge | Defines equipment, sensors, locations, and qualification context. | `Equipment`, `Sensor`, `Room`, `ManufacturingLine` |
| Execution evidence | Records what happened. | `ManufacturingRun`, `SensorReading`, `BatchRecord` |
| Quality evidence | Records quality events, results, and disposition. | `CQA`, `Specification`, `Alarm`, `Deviation`, `QAReleaseDecision` |
| Regulatory evidence | Connects product/process knowledge to CMC filing context. | `RegulatoryFiling`, `RegulatorySection`, `ValidationEvidence` |
| Data governance | Defines critical data, ownership, stewardship, standards, and quality. | `CriticalDataElement`, `DataOwner`, `DataSteward`, `DataQualityRule` |
| AI/RAG context | Helps agents retrieve and explain evidence. | `docs/rag-manifest.jsonl`, approved Cypher templates |

## Ownership And Stewardship

| Information Area | Typical Accountable Function |
| --- | --- |
| Product and formulation definitions | Product development / CMC |
| Process parameters and control strategy | MSAT / process engineering |
| Material data and supplier context | Supply chain / quality |
| Analytical methods and results | QC / analytical development |
| Batch record and execution data | Manufacturing / MES ownership |
| Deviations and release decisions | QA / QMS ownership |
| CDE definitions and data quality | Data owner and data steward |
| Regulatory mappings and filing evidence | Regulatory / CMC |
| Agent answer templates and retrieval context | Architecture / data platform / AI governance |

In the demo graph, these are represented through labels such as `DataOwner`, `DataSteward`, `EvidenceDocument`, `RegulatorySection`, and `ProvenanceStatement`.

## Navigation Model

Beginners can navigate the information architecture in this order:

1. Start with `Product`.
2. Move to `Formulation` and `Recipe`.
3. Follow recipe steps or end-to-end `UnitOperation` sequence.
4. Inspect material lots and equipment used by a `ManufacturingRun`.
5. Inspect readings, alarms, deviations, and QA decision.
6. Trace CDEs to owners, stewards, source systems, standards, and CMC sections.
7. Check evidence documents and provenance before trusting an answer.

## Information Lifecycle

```text
Definition
  Product, material, recipe, CDE, specification.

Execution
  Run, reading, alarm, batch record.

Review
  Deviation, QA decision, analytical result.

Evidence
  Validation evidence, provenance, audit trail, filing support.

Reuse
  Query, report, architecture workshop, agent answer, impact assessment.
```

## Beginner Example

If a stakeholder asks, "Can this batch be released?", the information architecture shows that the answer is not in one node.

It crosses:

- product and recipe context;
- material genealogy;
- process readings and specifications;
- alarms and deviations;
- batch record review;
- QA decision;
- evidence and provenance.

## Limitations

This model is a reference architecture view. In a real organization, ownership and system-of-record boundaries must be confirmed with actual business owners, quality functions, and system owners.
