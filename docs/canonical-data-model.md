# CDC Canonical Data Model

The canonical data model defines common data objects that can be shared across systems and integrations.

It is different from the Neo4j graph model. Neo4j is one implementation. A canonical model is a stable language for exchanging CDC manufacturing data between systems such as MES, LIMS, QMS, ERP, historians, document systems, Neo4j, and agents.

## Why This Model Exists

Source systems often use different names for the same business idea.

Example:

```text
MES: batchId
ERP: lotNumber
Historian: run tag
QMS: deviation reference
Neo4j: runId
```

A canonical model helps integration teams agree on the shared object before mapping each system-specific field.

## Primary Audience

| Audience | Why They Use This Model |
| --- | --- |
| Integration architects | To define common data objects across MES, LIMS, QMS, ERP, historians, documents, and Neo4j. |
| API and event designers | To shape payloads and contracts without leaking one source system's terminology everywhere. |
| Data platform teams | To design staging, transformation, and graph-loading patterns. |
| Enterprise architects | To reason about reusable information objects across domains and systems. |
| Client implementation teams | To map local source-system fields into a shared reference architecture. |

## Who Creates It In An Enterprise

The canonical data model is usually created by an **integration architect**, **enterprise data architect**, or **platform data architect**.

It should be co-designed with API/event designers, source-system owners, data governance leads, and the teams that will consume the canonical objects.

## How It Relates To Other Models

```text
Semantic data model
  explains the meaning of concepts.

Canonical data model
  defines common exchange objects and field groups.

Integration model
  explains which systems send and receive those objects.

Physical graph model
  stores connected instances in Neo4j.
```

The canonical model is especially useful when a client wants to adapt this reference architecture to their own systems.

## Canonical Objects

| Canonical Object | Purpose | Typical Source Systems |
| --- | --- | --- |
| `ProductDefinition` | Product identifier, strength, dosage form, formulation and CMC context. | ERP, PLM, regulatory/document systems |
| `MaterialDefinition` | Material master, role, grade, quality attributes. | ERP, LIMS, material master systems |
| `MaterialLotRecord` | Physical lot, supplier, release status, genealogy context. | ERP, LIMS, MES |
| `RecipeDefinition` | Versioned manufacturing recipe and step sequence. | MES, process development systems |
| `ProcessOperationRecord` | Unit operation, process step, equipment, timing and status. | MES, historian, DCS/PLC |
| `EquipmentAssetRecord` | Equipment identity, room, line, qualification and calibration context. | CMMS, MES, QMS |
| `SensorMeasurementRecord` | Sensor or PAT value with timestamp, units, limits and run context. | Historian, PAT, DCS/PLC |
| `QualityAttributeRecord` | CQA result, method, specification and status. | LIMS, PAT, MES |
| `CDEDefinitionRecord` | Critical data element definition, owner, steward, domain and source. | Data catalog, governance tool, spreadsheet |
| `CDEValueRecord` | Observed or representative value for a governed CDE. | Historian, MES, LIMS, QMS |
| `QualityEventRecord` | Alarm, deviation, investigation, severity and disposition context. | QMS, MES, historian |
| `BatchDispositionRecord` | Batch record review and QA release/rejection decision. | MES, QMS |
| `EvidenceRecord` | Document, validation, provenance, audit or filing evidence. | Document management, QMS, regulatory systems |

## Example Canonical Object

Example `SensorMeasurementRecord`:

```json
{
  "measurementId": "READ-001",
  "runId": "RUN-CDC-2026-06-01-001",
  "sensorId": "SEN-NIR-001",
  "measuredConceptId": "CQA-BLEND-UNIFORMITY",
  "timestamp": "2026-06-01T10:25:00Z",
  "value": 5.6,
  "unit": "%RSD",
  "lowerLimit": 0,
  "upperLimit": 6,
  "status": "Within limit",
  "sourceSystem": "PAT platform"
}
```

The same object can become:

- a message payload in an integration;
- a row in a staging table;
- a node and relationships in Neo4j;
- evidence used by an agent answer.

## Mapping To Neo4j

| Canonical Object | Neo4j Labels / Concepts |
| --- | --- |
| `ProductDefinition` | `Product`, `Formulation`, `Recipe`, `CMCPackage` |
| `MaterialLotRecord` | `MaterialLot`, `Material`, `Supplier` |
| `ProcessOperationRecord` | `ManufacturingRun`, `ProcessStep`, `UnitOperation`, `Equipment` |
| `SensorMeasurementRecord` | `SensorReading`, `Sensor`, `CPP`, `CQA`, `ManufacturingRun` |
| `CDEDefinitionRecord` | `CriticalDataElement`, `ValueDomain`, `DataOwner`, `DataSteward` |
| `CDEValueRecord` | `CDEValue`, `ManufacturingRun`, `EvidenceDocument` |
| `QualityEventRecord` | `Alarm`, `Deviation` |
| `BatchDispositionRecord` | `BatchRecord`, `QAReleaseDecision` |
| `EvidenceRecord` | `EvidenceDocument`, `ValidationEvidence`, `ProvenanceStatement`, `AuditTrailEvent` |

## Beginner Example

If a LIMS result and a PAT reading both measure blend uniformity, the canonical model gives them a shared target concept: `QualityAttributeRecord`.

The physical graph can then connect both values to the same `CQA` and relevant `CriticalDataElement`.

## Limitations

This canonical model is an illustrative reference. A real organization would need to align it with internal data contracts, naming standards, API schemas, event schemas, and system-specific constraints.
