# CDC Ontology Controlled Vocabularies

These vocabularies define recommended allowed values for the CDC ontology and CDE registry. In the current Neo4j demo, many of these values are stored as properties. In a fuller ontology or production implementation, they can be promoted into explicit controlled-vocabulary nodes.

## CDE Criticality

| Value | Meaning |
| --- | --- |
| `Critical` | Required to establish quality, genealogy, disposition, CMC evidence, control strategy, or data integrity. |
| `Important` | Useful for interpretation, investigation, continued process verification, or operational analytics. |

## CDE Domain

| Value | Meaning |
| --- | --- |
| `CPP` | Critical Process Parameter. |
| `CQA` | Critical Quality Attribute. |
| `CMA` | Critical Material Attribute. |
| `CPP/CMA` | Data element bridges process and material-attribute control. |
| `CQA/CMA` | Data element bridges quality and material-attribute interpretation. |
| `CQA/IPC` | Quality attribute measured as an in-process control. |
| `CQA/PAT` | Quality attribute measured or predicted by PAT. |
| `Genealogy` | Data element required for material or batch traceability. |
| `Genealogy/CMA` | Data element supports both genealogy and material attribute context. |
| `Genealogy/QMS` | Data element supports genealogy and quality-system review. |
| `Disposition` | Data element supports QA disposition. |
| `Regulatory metadata` | Data element supports CMC or regulatory mapping. |

## Unit Operation Type

| Value | Meaning |
| --- | --- |
| `Drug substance unit operation` | Operation in drug substance formation or isolation. |
| `Particle engineering` | Operation controlling API particle characteristics. |
| `Material handling` | Controlled transfer, storage, or hold operation. |
| `CDC unit operation` | Continuous Direct Compression drug product operation. |
| `Drug product finishing` | Coating or finishing operation. |
| `Finished product collection` | Final collection and containerization operation. |
| `Quality and regulatory review` | Review operation for QA, CMC, and evidence. |

## Process Mode

| Value | Meaning |
| --- | --- |
| `Batch` | Discrete batch operation. |
| `Semi-continuous` | Operation with repeated or segmented continuous-like execution. |
| `Continuous` | Continuous process operation. |
| `Controlled hold` | Controlled storage or hold state. |
| `Review` | Review or disposition activity rather than physical processing. |

## Data Quality Dimension

| Value | Meaning |
| --- | --- |
| `Completeness` | Required data exists. |
| `Validity` | Data conforms to approved value range or business rule. |
| `Consistency` | Data uses controlled units, identifiers, and formats. |
| `Timeliness` | Data has appropriate timestamp and timing context. |
| `Traceability` | Data links to relevant material, process, source, or evidence lineage. |
| `Data integrity` | Data supports ALCOA+ expectations in validated contexts. |

## Data Source System Type

| Value | Meaning |
| --- | --- |
| `Control system` | DCS, PLC, or process control layer. |
| `Time-series historian` | Historian for process values. |
| `PAT / model system` | PAT model or analytical prediction system. |
| `Laboratory information management` | LIMS or laboratory results system. |
| `Manufacturing execution` | MES or electronic batch record. |
| `Quality management system` | QMS for deviations, CAPA, change, and disposition. |
| `Enterprise resource planning` | ERP or material management system. |
| `Environmental monitoring` | EMS for room or cleanroom environment. |

## ISA-95 Level

| Value | Meaning |
| --- | --- |
| `Level 2` | Control and supervisory control systems. |
| `Level 2/3` | Boundary between control and manufacturing operations systems. |
| `Level 3` | Manufacturing operations management, MES, LIMS, historian context. |
| `Level 4` | Enterprise systems such as ERP, QMS, and regulatory/business systems. |

## Run Status

| Value | Meaning |
| --- | --- |
| `Planned` | Run planned but not started. |
| `In progress` | Run is executing. |
| `Completed` | Run execution complete but not necessarily released. |
| `Released` | Run released by QA. |
| `Rejected` | Run rejected by QA. |
| `Quarantined` | Run or material is on hold. |

## Deviation Severity

| Value | Meaning |
| --- | --- |
| `Minor` | Low quality impact or procedural event. |
| `Major` | Potential or actual quality impact requiring formal investigation. |
| `Critical` | Significant quality or patient-impact risk. |

## QA Decision

| Value | Meaning |
| --- | --- |
| `Release` | Batch/run released. |
| `Reject` | Batch/run rejected. |
| `Quarantine` | Batch/run held pending further review. |

## CDE Value Status

| Value | Meaning |
| --- | --- |
| `Verified` | Representative value has been checked against its demo source context. |
| `Calculated` | Representative value is derived from source data or a calculation. |
| `Reviewed` | Representative value has been reviewed as part of QA, CMC, or architecture review. |

## Value Domain Type

| Value | Meaning |
| --- | --- |
| `Numeric` | Value is represented as a number and normally has a unit or range. |
| `Identifier` | Value is a controlled identifier such as a lot, batch, or container ID. |
| `Categorical` | Value must come from an allowed-value list. |
| `Text` | Value is descriptive text and needs stronger governance before analytics use. |

## Standard Type

| Value | Meaning |
| --- | --- |
| `ICH guideline` | ICH quality or regulatory guideline. |
| `Regulatory dossier structure` | CTD or eCTD structure. |
| `Metadata registry standard` | Data element and metadata governance standard. |
| `Cleanroom standard` | Controlled environment standard. |
| `Manufacturing KPI standard` | Manufacturing performance and KPI standard. |
| `Manufacturing integration standard` | Enterprise-control system integration standard. |
