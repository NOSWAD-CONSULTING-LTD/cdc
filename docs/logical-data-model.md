# CDC Logical Data Model

The logical data model explains the main entities, identifiers, attributes, relationships, and rules in a database-neutral way.

It sits between the semantic data model and the physical Neo4j graph. A beginner can think of it as the point where business meaning starts becoming implementable structure, but before choosing labels, indexes, constraints, or Cypher scripts.

## Why This Model Exists

The logical model helps answer:

- Which entities do we need?
- What stable identifiers should each entity have?
- Which relationships are required?
- Which attributes matter for interpretation?
- Which rules should hold before the data is trusted?

It is useful for data architects, solution architects, ontology modelers, integration teams, and anyone reviewing whether the graph has enough structure to support traceability and AI-assisted answers.

## Primary Audience

| Audience | Why They Use This Model |
| --- | --- |
| Data architects | To check entities, identifiers, attributes, relationships, and rules before implementation. |
| Solution architects | To understand the stable structure that applications and integrations depend on. |
| Ontology modelers | To align formal classes and predicates with implementable entities and relationships. |
| Integration engineers | To know which identifiers and relationships must be populated from source systems. |
| AI/RAG engineers | To understand which graph structures are reliable enough for evidence-grounded answers. |

## Who Creates It In An Enterprise

The logical data model is usually created by a **data architect** or **solution data architect**, with input from domain SMEs, integration architects, ontology modelers, and source-system owners.

In regulated manufacturing, quality, MSAT, CMC, and data governance representatives should review the model before it is treated as authoritative.

## How It Relates To Other Models

```text
Conceptual model
  says what the business process is.

Semantic data model
  says what the concepts and relationships mean.

Logical data model
  says which entities, identifiers, attributes, and relationship rules are needed.

Ontology
  formalizes the meaning as classes, predicates, vocabularies, and constraints.

Physical Neo4j model
  implements the logical and semantic choices as labels, properties, constraints, indexes, and relationships.
```

## Core Logical Entities

| Entity | Stable Identifier | Why It Exists |
| --- | --- | --- |
| `Product` | `productId` | Identifies the manufactured medicinal product. |
| `Formulation` | `formulationId` | Defines product composition and version context. |
| `Recipe` | `recipeId` | Defines the manufacturing process to execute. |
| `ProcessStep` | `stepId` | Defines ordered recipe steps for execution. |
| `UnitOperation` | `unitOperationId` | Defines conceptual process stages across the end-to-end flow. |
| `Material` | `materialId` | Defines material master data. |
| `MaterialLot` | `lotId` | Identifies physical lots used in genealogy. |
| `Supplier` | `supplierId` | Identifies material source organizations. |
| `Equipment` | `equipmentId` | Identifies assets used by process steps or operations. |
| `Sensor` | `sensorId` | Identifies instruments, historian tags, PAT models, or soft sensors. |
| `ManufacturingRun` | `runId` | Identifies executed manufacturing events. |
| `SensorReading` | `readingId` | Identifies run-specific process or quality values. |
| `CPP` | `cppId` | Identifies critical process parameter definitions. |
| `CQA` | `cqaId` | Identifies critical quality attribute definitions. |
| `CriticalDataElement` | `cdeId` | Identifies governed data element definitions. |
| `CDEValue` | `cdeValueId` | Identifies observed or representative values of a CDE. |
| `EvidenceDocument` | `documentId` | Identifies document-style evidence anchors. |
| `QAReleaseDecision` | `decisionId` | Identifies QA disposition decisions. |

## Required Relationship Groups

### Product And Process Definition

```text
Product HAS_FORMULATION Formulation
Product HAS_RECIPE Recipe
Recipe DEFINES_STEP ProcessStep
Formulation USES_MATERIAL Material
```

These relationships define what should be made and how.

### Execution And Genealogy

```text
ManufacturingRun EXECUTES Recipe
ManufacturingRun CONSUMES MaterialLot
MaterialLot INSTANCE_OF Material
MaterialLot SUPPLIED_BY Supplier
ManufacturingRun HAS_BATCH_RECORD BatchRecord
```

These relationships define what actually happened during a run.

### Quality And Control

```text
CPP CONTROLS ProcessStep
CPP IMPACTS CQA
CQA HAS_SPECIFICATION Specification
Sensor MEASURES CPP or CQA
SensorReading RECORDED_BY Sensor
SensorReading DURING_RUN ManufacturingRun
```

These relationships explain how process evidence connects to quality interpretation.

### CDE Governance

```text
CriticalDataElement OBSERVED_AT UnitOperation
CriticalDataElement SOURCED_FROM DataSourceSystem
CriticalDataElement HAS_OWNER DataOwner
CriticalDataElement HAS_STEWARD DataSteward
CriticalDataElement HAS_VALUE_DOMAIN ValueDomain
CDEValue VALUE_OF CriticalDataElement
CDEValue OBSERVED_DURING ManufacturingRun
```

These relationships separate metadata definitions from actual value evidence.

## Logical Rules

The logical model expects these rules:

- major entities should have stable IDs;
- a manufacturing run should execute one recipe;
- a material lot should instantiate one material master;
- a sensor reading should have a sensor and run context;
- a CDE should have owner, steward, source system, value domain, and standard/CMC context where applicable;
- a CDE value should point to the CDE definition it instantiates;
- QA release or rejection should be linked to a batch record and manufacturing run;
- standards mappings should have provenance where possible.

## Beginner Example

Suppose someone asks, "Which supplier may have affected this released run?"

The logical model says the required path is:

```text
ManufacturingRun -> MaterialLot -> Material -> Supplier
```

The physical Neo4j query can then use:

```cypher
MATCH (run:ManufacturingRun)-[:CONSUMES]->(lot:MaterialLot)-[:INSTANCE_OF]->(material:Material)
MATCH (lot)-[:SUPPLIED_BY]->(supplier:Supplier)
RETURN run.runId, lot.lotNumber, material.name, supplier.name;
```

## Limitations

This logical model is intentionally simplified. It is a reference architecture model, not a complete enterprise logical model for a real manufacturer.
