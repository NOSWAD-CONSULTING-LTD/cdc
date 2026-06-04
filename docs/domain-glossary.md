# Reference Architecture for CDC Manufacturing: Ubiquitous Language

This glossary defines the shared domain language for the Continuous Direct Compression (CDC) Neo4j demo. It is intended for information architects, ontology modelers, manufacturing data architects, quality teams, and regulatory stakeholders.

The definitions are production-inspired but simplified for demo use. They are not controlled GxP definitions.

## Acronym Quick Reference

| Acronym | Expansion | Meaning In This Model |
| --- | --- | --- |
| A4 | ISO 216 A4 paper size | Printable page size used for the diagram HTML files. |
| AI | Artificial Intelligence | Intended consumer of the AI-ready graph, RAG manifest, provenance, and CDE metadata. |
| ALCOA+ | Attributable, Legible, Contemporaneous, Original, Accurate, plus Complete, Consistent, Enduring, and Available | Data integrity principle represented through audit trail, source system, and review evidence. |
| API | Active Pharmaceutical Ingredient | Active material in the tablet formulation. |
| NCL | NOSWAD CONSULTING LTD reference-architecture prefix | Demo product prefix used to avoid resemblance to a real medicine sponsor code. |
| CAPA | Corrective and Preventive Action | Deviation follow-up concept represented as text in this demo. |
| CDC | Continuous Direct Compression | Continuous tablet manufacturing route using direct compression. |
| CDE | Critical Data Element | Governed data element important to quality, genealogy, CMC, disposition, or data integrity. |
| CMA | Critical Material Attribute | Material attribute that can affect process performance or product quality. |
| CMC | Chemistry, Manufacturing, and Controls | Regulatory quality information covering composition, process, controls, methods, validation, stability, and evidence. |
| CPP | Critical Process Parameter | Process parameter monitored or controlled because it can affect CQAs. |
| CQA | Critical Quality Attribute | Product quality attribute linked to safety, quality, or performance. |
| CSV | Computer System Validation | Validation evidence for computerized systems and regulated data sources. |
| CTD | Common Technical Document | Regulatory dossier structure; this demo maps CDEs to CTD Module 3 CMC sections. |
| DCS | Distributed Control System | Control-system source for process values. |
| EBR | Electronic Batch Record | MES/batch record context for execution and review evidence. |
| EMA | European Medicines Agency | Regulatory agency referenced in provenance/source context. |
| EMS | Environmental Monitoring System | Source system for room or cleanroom environmental data. |
| ERP | Enterprise Resource Planning | Source system for material, supplier, or inventory context. |
| FDA | U.S. Food and Drug Administration | Regulatory agency referenced in provenance/source context. |
| FMEA | Failure Mode and Effects Analysis | Risk assessment method represented by the demo risk assessment node. |
| GMP | Good Manufacturing Practice | Regulated manufacturing quality context; this demo is not a validated GMP system. |
| HPLC | High-Performance Liquid Chromatography | Analytical method context for content uniformity and assay-related CQAs. |
| ICH | International Council for Harmonisation | Pharmaceutical quality/regulatory guidance context used in standards mappings. |
| IEC | International Electrotechnical Commission | Standards body referenced with ISA-95 / IEC 62264. |
| IPC | In-Process Control | Quality or process check performed during manufacturing. |
| IQ/OQ/PQ | Installation Qualification / Operational Qualification / Performance Qualification | Equipment qualification lifecycle evidence. |
| ISA-95 | Enterprise-control integration standard, also IEC 62264 | Used to classify source-system boundaries and manufacturing hierarchy levels. |
| ISO | International Organization for Standardization | Standards body referenced for metadata, cleanroom, and manufacturing KPI standards. |
| KPI | Key Performance Indicator | Manufacturing performance measure context, for example reject rate or yield. |
| LIMS | Laboratory Information Management System | Source system for laboratory results and analytical testing context. |
| LOD | Loss on Drying | Drying endpoint or residual moisture/solvent indicator. |
| MCC | Microcrystalline Cellulose | Excipient used in the demo formulation. |
| MES | Manufacturing Execution System | Source system for execution, batch record, and manufacturing review data. |
| MOM | Manufacturing Operations Management | Manufacturing operations layer referenced by ISO 22400 KPI context. |
| MSAT | Manufacturing Science and Technology | Business owner/stewardship function for process and product knowledge. |
| NIR | Near-Infrared | PAT measurement technology used for blend uniformity in the demo. |
| PAT | Process Analytical Technology | In-process analytical measurement or model used to monitor/control quality. |
| PLC | Programmable Logic Controller | Control-system source for equipment/process values. |
| PPQ | Process Performance Qualification | Process validation evidence context. |
| PSD | Particle Size Distribution | Material attribute relevant to API/crystal/milled particle control. |
| QA | Quality Assurance | Function responsible for batch review, deviation assessment, and release decision. |
| QbD | Quality by Design | Pharmaceutical development concept related to process understanding and control strategy. |
| QC | Quality Control | Laboratory/testing function for analytical results and quality checks. |
| QMS | Quality Management System | Procedures, training, deviations, change control, and quality records. |
| RAG | Retrieval-Augmented Generation | AI pattern using retrieved project docs/graph context to answer questions. |
| RDF/OWL | Resource Description Framework / Web Ontology Language | Machine-readable ontology representation style used by `cdc-ontology.ttl`. |
| RH | Relative Humidity | Environmental CPP used in room/coating contexts. |
| RSD | Relative Standard Deviation | Variability statistic used for blend uniformity examples. |
| SHACL | Shapes Constraint Language | RDF validation language used by `cdc-shacl-shapes.ttl`. |
| SOP | Standard Operating Procedure | Controlled procedure governing manufacturing, review, or quality activities. |
| UOM | Unit of Measure | Controlled unit associated with a value domain. |
| USP | United States Pharmacopeia | Compendial quality context referenced in demo material/method language. |

## Core Product And Process Terms

| Term | Meaning In This Model | Example |
| --- | --- | --- |
| Product | The medicinal product being manufactured and controlled. | `NCL-CDC-Tablet-10mg` |
| NCL | NOSWAD CONSULTING LTD reference-architecture prefix used for demo product and batch identifiers. It is not a real medicine identifier. | `NCL-CDC-Tablet-10mg` |
| Formulation | Versioned composition of API and excipients for a product. | `FORM-NCL-CDC-10MG-F001` |
| Recipe | Versioned manufacturing process definition used to execute a run. | `REC-NCL-CDC-DC-001` |
| ProcessStep | Ordered unit of work within the recipe. | API feeding, continuous blending, tablet compression |
| CDC | Continuous Direct Compression; a continuous tablet manufacturing route using direct compression rather than wet granulation. | Direct compression tablet process |
| ManufacturingRun | Executed manufacturing event using a recipe, line, material lots, equipment, and batch record. | `RUN-CDC-2026-06-01-001` |
| Batch Number | Business identifier for the output batch or run disposition unit. | `NCLCDC10-260601` |

## Materials And Genealogy

| Term | Meaning In This Model | Example |
| --- | --- | --- |
| Material | Material master record for API, excipient, or lubricant. | Microcrystalline cellulose PH102 |
| MaterialLot | Physical lot of material received, released, and consumed. | `LOT-API-NCL-240501-A` |
| Supplier | Qualified source of material or lot supply. | DirectComp Excipients Ltd |
| Material Genealogy | Traceability from product/run back to consumed lots, materials, and suppliers. | Run consumes API lot supplied by internal API network |
| API | Active pharmaceutical ingredient. | NCL active pharmaceutical ingredient |
| Excipient | Non-API formulation component with a functional role. | MCC, lactose, croscarmellose sodium |
| Lubricant | Excipient used to support compression and ejection. | Magnesium stearate |
| CMA | Critical Material Attribute; material attribute that can affect process performance or product quality. | API particle size distribution |

## Equipment, Sensors, And Data

| Term | Meaning In This Model | Example |
| --- | --- | --- |
| ManufacturingSite | Facility where the process is executed. | Cambridge CDC Demonstration Facility |
| ManufacturingLine | Integrated line that executes the CDC process. | `LINE-CDC-01` |
| Room | Controlled manufacturing area where equipment is located. | Compression suite 103 |
| Equipment | Physical asset used by a process step. | Tablet press, continuous blender |
| Sensor | Instrument, historian tag, PAT model, or soft sensor that records a parameter. | Inline NIR blend uniformity |
| SensorReading | Time-stamped value recorded by a sensor during a manufacturing run. | NIR blend uniformity `%RSD` at 10:20 |
| Historian | Time-series data system for process and sensor values. | CDC historian demo |
| PAT | Process Analytical Technology used for in-process measurement or prediction. | Inline NIR model |

## CPP, CQA, And Specifications

| Term | Meaning In This Model | Example |
| --- | --- | --- |
| CPP | Critical Process Parameter; process parameter monitored or controlled because it can affect CQAs. | Compression force |
| CQA | Critical Quality Attribute; measurable product quality attribute linked to safety, quality, or performance. | Content uniformity |
| Specification | Acceptance criterion or limit for a CQA. | Tablet weight 190-210 mg |
| ControlStrategy | Integrated set of material, process, analytical, and quality controls intended to protect CQAs. | CDC integrated control strategy |
| In-Process Control | Control or monitoring activity performed during manufacturing. | In-process tablet weight control |
| Design Space | Multidimensional operating region where quality is expected to be assured. Not explicitly modeled as validated design space in this demo. | Potential extension |
| Continued Process Verification | Ongoing monitoring of process performance after validation. Not fully implemented in this demo. | Potential extension |

## Quality Events And Disposition

| Term | Meaning In This Model | Example |
| --- | --- | --- |
| Alarm | System-generated event triggered by a reading or condition. | NIR blend uniformity high alarm |
| Deviation | Quality investigation for an unexpected event, excursion, or nonconformance. | Humidity drift and PAT excursion |
| CAPA | Corrective and Preventive Action. In this demo it is represented as deviation `capa` text, not a full CAPA workflow. | Tightened humidity alarm response |
| BatchRecord | Electronic batch record summary containing execution and review evidence. | `BR-NCLCDC10-260601` |
| QAReleaseDecision | QA disposition decision after batch record and deviation review. | Release |
| CleaningRecord | Evidence that line or equipment cleaning/clearance was performed. | Post-run product-contact clean |
| CalibrationRecord | Evidence that instrument or equipment calibration was acceptable. | NIR calibration in tolerance |
| AuditTrailEvent | Data integrity evidence recording who/what changed or captured a regulated event. | Alarm acknowledged |

## CMC And Regulatory Terms

| Term | Meaning In This Model | Example |
| --- | --- | --- |
| CMC | Chemistry, Manufacturing, and Controls; regulatory body of information covering product composition, process, controls, analytical methods, validation, stability, facilities, and evidence. | `CMC-NCL-CDC-10MG-001` |
| CMCPackage | Graph node representing the product's CMC knowledge package. | NCL-CDC 10 mg CMC package |
| RegulatoryFiling | Filing or evidence package that covers the product and submits/supports CMC information. | Module 3 demo filing |
| ValidationEvidence | Evidence artifact supporting filing, validation, control strategy, or data integrity claims. | NIR model validation |
| ProcessValidation | Validation package connecting recipe, run evidence, and PPQ/control strategy. | CDC PPQ demo package |
| AnalyticalMethod | Method used to measure or verify a CQA. | HPLC content uniformity method |
| StabilityStudy | Study that monitors quality over time under defined storage conditions. | 25C/60%RH and 40C/75%RH protocol |
| RegulatoryCommitment | Commitment made in a filing. Not explicitly modeled in the current seed data; can be added as a governed node. | Potential extension |

## ISO, GMP, And QMS Terms

| Term | Meaning In This Model | Example |
| --- | --- | --- |
| QMS | Quality Management System; procedures, responsibilities, controls, and records governing quality activities. | SOPs, training, change control |
| SOP | Standard Operating Procedure governing an activity. | CDC deviation triage SOP |
| TrainingRecord | Evidence that an operator is trained on an SOP or process. | QA reviewer trained on deviation SOP |
| EquipmentQualification | Qualification evidence for equipment fitness for intended use. | IQ/OQ/PQ demo package |
| ComputerSystemValidation | Validation evidence for computerized systems involved in regulated data or execution. | CDC historian validation |
| ChangeControl | Governed assessment and approval of a proposed change. | NIR model update |
| DataIntegrityControl | Controls supporting ALCOA+ principles. In this demo represented through audit trail, batch review, and CSV nodes. | Audit trail event documents QA decision |

## End-To-End Process And CDE Terms

| Term | Meaning In This Model | Example |
| --- | --- | --- |
| ProcessSegment | High-level segment of the end-to-end manufacturing flow. | Drug substance formation and isolation |
| UnitOperation | Conceptual process stage from crystallisation to coated tablet collection. | Crystallisation, drying, compression, powder coating |
| Crystallisation | Drug substance unit operation where API crystals are formed from solution or slurry. | Supersaturation and cooling rate control |
| Isolation / Filtration / Washing | Drug substance unit operation separating crystals and washing the wet cake. | Wash solvent volume |
| Drying | Unit operation reducing residual solvent or moisture to an acceptable endpoint. | Loss on drying endpoint |
| Milling / Micronisation / Sieving | Particle engineering operations controlling API particle size and flow properties. | Milled API particle size distribution |
| API Intermediate Handling | Controlled storage, transfer, and hold-time management of API intermediate. | API intermediate hold time |
| Semi-Continuous Powder Coating | Drug product finishing operation applying dry coating powder to core tablets in a controlled semi-continuous mode. | Coating powder feed rate |
| Powder Coated Tablet | Final conceptual product state after coating and collection. | Powder coated tablet container ID |
| MaterialTransformation | Material state change across a unit operation. | Wet cake to dried API |
| IntermediateProduct | Material state produced by a unit operation and available for genealogy or sampling. | Dried API intermediate |
| ProcessState | Conceptual process condition or state. Extension concept only; it is not populated as a node label in the current demo graph. | Controlled hold |
| SamplingPoint | Location or event where sample or PAT data is collected. | Inline blend PAT point |
| ControlPoint | Point where monitoring or control is applied to maintain process state or product quality. | Tablet weight control point |
| AnalyticalResult | Result from an analytical test or method. Extension concept only; detailed analytical result nodes are not populated in the current demo graph. | Residual solvent result |

## Critical Data Element Governance Terms

| Term | Meaning In This Model | Example |
| --- | --- | --- |
| CriticalDataElement | Governed metadata record for a data element that is important to quality, genealogy, disposition, control, CMC evidence, or data integrity. It is not the raw measurement itself. | Inline NIR blend uniformity |
| CDE Domain | Classification of what the CDE represents. | CPP, CQA, CMA, Genealogy |
| CDE Criticality | Indicates whether the CDE is `Critical` or `Important` for this conceptual architecture. | Critical |
| DataSourceSystem | System of record or source system where the CDE value originates. | Process historian |
| DataOwner | Business function accountable for the CDE. | MSAT |
| DataSteward | Role responsible for CDE definition quality, metadata consistency, and stewardship. | Drug product data steward |
| DataQualityRule | Rule used to assess required quality of a CDE. | Timestamp integrity rule |
| StandardMapping | Explicit mapping between a CDE, a standard, and optionally a CMC regulatory section. | CDE-CDC-BLEND-NIR to ICH Q13 |
| RegulatorySection | CTD Module 3 or CMC section supported by a CDE. | 3.2.P.3.4 Controls of Critical Steps and Intermediates |
| DataStandard | ICH, ISO, ISA, or CTD standard/guidance context used for architecture mapping. | ISO/IEC 11179 |
| Source System Boundary | Architecture concept describing where a data element originates and which system owns the authoritative record. | DCS versus MES versus LIMS |
| ISA-95 Level | Enterprise-control architecture layer used to classify source systems. | Level 2 control system, Level 3 MES |
| ValueDomain | Data type, unit, and allowed-value context for a CDE. | Numeric mass flow in kg/h |
| UnitOfMeasure | Controlled unit used by a value domain. | kg/h |
| AllowedValue | Controlled permissible value for a categorical value domain. | Release |
| CDEVersion | Versioned CDE definition used for governance and change history. | CDE-CDC-BLEND-NIR-V1 |
| CDEDefinitionApproval | Approval record for a CDE definition version. | CDE definition accepted for demo AI-readiness review |
| CDEValue | Representative observed or textual value for a CDE. It is distinct from the CDE definition. | Inline NIR blend uniformity = 5.6 %RSD |
| ProvenanceStatement | Citation, source URL, confidence, and retrieval date supporting a standard or mapping. | FDA ICH Q13 guidance page |
| EvidenceDocument | Fictional document-style evidence node supporting CDE values, mappings, batch records, QA decisions, validation evidence, or filing context. | Demo NIR trend extract |
| CDEDomain | Graph node representing controlled vocabulary for CDE domain classification. | CQA |
| CriticalityLevel | Graph node representing controlled vocabulary for CDE criticality. | Critical |
| DecisionStatus | Graph node representing controlled vocabulary for QA decision or disposition values. | Release, Reject |
| RunStatus | Graph node representing controlled vocabulary for manufacturing run status. | Released, Rejected |
| DeviationSeverity | Graph node representing controlled vocabulary for deviation severity. | Major, Critical |
| RelationshipDefinition | Machine-readable relationship mapping between a Neo4j relationship type and an ontology predicate. | `REJECTS` -> `rejects` |
| RAG Manifest | Machine-readable list of documents/chunks and the questions they help answer. | docs/rag-manifest.jsonl |
| JSONL | JSON Lines format: one JSON object per line. Useful for manifests and retrieval catalogs. | One RAG manifest record per line |
| RAG | Retrieval-Augmented Generation: retrieving relevant project context before asking an AI model to answer. | Retrieve glossary and query pack before answering |
| Ontology | Formal semantic model of classes, relationships, meanings, and constraints. | CDC ontology guide and Turtle file |
| Semantic Data Model | Business-facing model that explains the meaning of concepts and relationships before they are formalized in the ontology or implemented in Neo4j. | `docs/semantic-data-model.md` |
| Semantics | The meaning of data and relationships, not just their storage format. | `VALUE_OF` means an observed value instantiates a CDE definition |
| Knowledge Graph | Graph that connects data with meaning, lineage, governance, and evidence. | CDC manufacturing graph |
| Conceptual Model | Business-level model explaining important concepts and relationships. | Crystallisation-to-coating process model |
| Logical Model | More structured model of entities, identifiers, relationships, and rules. | CDE catalog and relationship matrix |
| Canonical Data Model | Common exchange model used to map different source-system records into shared objects. | SensorMeasurementRecord maps to SensorReading |
| Information Architecture Model | Model explaining domains, ownership, stewardship, source-system boundaries, navigation, and lifecycle. | Product knowledge, quality evidence, data governance |
| Integration Model | Model explaining how data moves between source systems, canonical objects, Neo4j, documents, and agents. | MES -> canonical object -> Neo4j |
| Provenance And Evidence Model | Model explaining how values, decisions, mappings, and answers are supported by traceable evidence. | Deviation -> Alarm -> SensorReading |
| Physical Model | Implemented database structure and scripts. | Neo4j labels, relationships, constraints, and Cypher seeds |
| Model Stack | Ordered set of modeling layers from glossary and conceptual model through semantic, logical, canonical, information, integration, provenance, ontology, physical graph, and agent/RAG interpretation. | Glossary -> semantic model -> ontology -> Neo4j |

## Standards Used In The CDE Model

| Term | Meaning In This Model | Example |
| --- | --- | --- |
| ICH Q13 | Continuous manufacturing context for drug substance and drug product process control, monitoring, and regulatory evidence. | Continuous blending CDEs |
| CTD Module 3 / ICH M4Q | CMC quality dossier structure used to map CDEs to regulatory sections. | 3.2.P.3.3 manufacturing process |
| ISO/IEC 11179 | Metadata registry standard used as the conceptual basis for CDE definition, naming, classification, identification, and mapping. | CriticalDataElement registry |
| ISO 14644 | Cleanroom and controlled-environment context for room and environmental CDEs. | Relative humidity |
| ISO 22400 | Manufacturing operations KPI context. | Reject rate, yield, performance indicators |
| ISA-95 / IEC 62264 | Enterprise-control system integration framework used to classify source-system boundaries. | DCS, historian, MES, ERP |
| ICH Q14 | Analytical procedure development context for analytical and PAT-related CDEs. | NIR blend uniformity method |

## Data Architecture Categories

| Term | Meaning In This Model | Examples |
| --- | --- | --- |
| Master Data | Stable governed entities that exist outside a single run. | Product, Material, Recipe, Equipment, Sensor |
| Reference Data | Controlled classifications, vocabularies, limits, and interpretation context. | Material roles, equipment types, alarm severities, specification limits |
| Transactional Data | Evidence of what happened during execution or review. | ManufacturingRun, SensorReading, Alarm, Deviation, QAReleaseDecision |
| Evidence Graph | Connected record of data and documents supporting a conclusion. | Run -> BatchRecord -> QAReleaseDecision -> RegulatoryFiling |
| Stable ID | Durable identifier used for idempotent graph loading and entity resolution. | `runId`, `materialId`, `equipmentId` |

## Modeling Principles

- Prefer explicit nodes for concepts that need governance, ownership, versioning, approval, lineage, or reuse.
- Keep high-cardinality events such as `SensorReading` transactional and connect them to master/reference context.
- Use relationships to make evidence trails explainable: what happened, what it affected, what controlled it, and what evidence supports the decision.
- Do not treat this demo as a validated GxP system. A real implementation would require controlled vocabularies, audit trails, access controls, validation, change control, data retention, and quality approval.
