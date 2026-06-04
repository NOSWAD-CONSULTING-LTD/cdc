# Reference Architecture for CDC Manufacturing Knowledge Graphs

[![Neo4j 5](https://img.shields.io/badge/Neo4j-5-4581C3)](https://neo4j.com/)
[![Laravel](https://img.shields.io/badge/Laravel-Agent-FF2D20)](https://laravel.com/)
[![Laravel Herd](https://img.shields.io/badge/Laravel-Herd-6B7280)](https://herd.laravel.com/)
[![Licence](https://img.shields.io/badge/Licence-Apache--2.0%20%2B%20CC--BY--4.0-blue)](LICENSE)
[![Sponsor](https://img.shields.io/badge/Sponsor-NOSWAD%20CONSULTING%20LTD-0E7A5F)](https://github.com/sponsors/NOSWAD-CONSULTING-LTD)

This project is a Neo4j 5 reference architecture for pharmaceutical Continuous Direct Compression (CDC) manufacturing knowledge graphs. It is production-inspired demo data for information architecture, ontology, manufacturing data architecture, AI-readiness, and traceability discussions.

It models a realistic CDC tablet process around `NCL-CDC-Tablet-10mg`: product and formulation master data, ordered recipe steps, materials and suppliers, equipment and sensors, CPPs, CQAs and specifications, material lot genealogy, manufacturing runs, process readings, alarms, deviation investigations, batch record review, QA release/rejection, regulatory evidence, CDE governance, and AI-readiness evidence.

`NCL-CDC-Tablet-10mg` is a fictional safe demo product name. In this project, `NCL` is the NOSWAD CONSULTING LTD reference-architecture prefix, `CDC` means Continuous Direct Compression, `Tablet` is the dosage form, and `10mg` is the strength. It is not intended to identify a real medicine or real commercial product.

## Why Neo4j?

Neo4j was chosen because CDC manufacturing knowledge is naturally connected data. The important questions are rarely about one table in isolation; they are about paths across product definitions, recipes, equipment, sensors, material lots, process readings, deviations, QA decisions, CMC evidence, standards, and ontology concepts.

Neo4j is useful for this reference architecture because it can:

- trace genealogy from finished batch back to consumed material lots and suppliers;
- show process topology from crystallisation through compression and powder coating;
- connect CPPs, CQAs, CDEs, specifications, alarms, deviations, and QA disposition evidence;
- support ontology and ubiquitous-language discussions using explicit node labels and relationship types;
- make regulatory and validation evidence traversable instead of hidden in disconnected documents;
- provide graph paths that are easy to inspect in Neo4j Browser during architecture workshops;
- ground AI/RAG answers in explicit evidence paths rather than untraceable text-only summaries.

This does not mean all source data should live only in Neo4j. In a real enterprise architecture, MES, LIMS, QMS, ERP, historians, document systems, and regulatory systems remain systems of record. Neo4j is used here as a connected knowledge layer that links those records into an explainable manufacturing and quality context.

## Keywords And Discoverability

This repository is intended for people searching for practical examples of:

- pharmaceutical manufacturing knowledge graphs;
- Continuous Direct Compression (CDC) manufacturing data architecture;
- Neo4j manufacturing genealogy and batch traceability;
- AI-ready manufacturing data and graph-grounded RAG;
- Critical Data Element (CDE) governance;
- CMC evidence traceability and regulatory knowledge management;
- ontology, semantic modeling, and ubiquitous language for pharma manufacturing;
- Laravel AI agents using approved Cypher templates and Neo4j evidence.

## Start Neo4j

```bash
docker compose up -d
```

Neo4j Browser will be available at [http://localhost:7474](http://localhost:7474).

Use:

- Username: `neo4j`
- Password: `cdc-demo-password`
- Bolt URL: `bolt://localhost:7687`

To stop Neo4j:

```bash
docker compose down
```

To remove the database volume and start fresh:

```bash
docker compose down -v
```

## Load The Graph

Run the files in this order. From the host machine:

```bash
docker compose exec neo4j cypher-shell -u neo4j -p cdc-demo-password -f /cypher/01_constraints.cypher
docker compose exec neo4j cypher-shell -u neo4j -p cdc-demo-password -f /cypher/02_seed_reference_data.cypher
docker compose exec neo4j cypher-shell -u neo4j -p cdc-demo-password -f /cypher/03_seed_manufacturing_run.cypher
docker compose exec neo4j cypher-shell -u neo4j -p cdc-demo-password -f /cypher/05_seed_cmc_qms_extension.cypher
docker compose exec neo4j cypher-shell -u neo4j -p cdc-demo-password -f /cypher/07_seed_end_to_end_cde_model.cypher
docker compose exec neo4j cypher-shell -u neo4j -p cdc-demo-password -f /cypher/09_seed_ai_readiness_enrichment.cypher
docker compose exec neo4j cypher-shell -u neo4j -p cdc-demo-password -f /cypher/12_security_agent_user.cypher
```

Then copy queries from the query files into Neo4j Browser, or run them with:

```bash
docker compose exec neo4j cypher-shell -u neo4j -p cdc-demo-password -f /cypher/04_queries.cypher
docker compose exec neo4j cypher-shell -u neo4j -p cdc-demo-password -f /cypher/06_cmc_qms_queries.cypher
docker compose exec neo4j cypher-shell -u neo4j -p cdc-demo-password -f /cypher/08_end_to_end_cde_queries.cypher
docker compose exec neo4j cypher-shell -u neo4j -p cdc-demo-password -f /cypher/10_ai_readiness_checks.cypher
docker compose exec neo4j cypher-shell -u neo4j -p cdc-demo-password -f /cypher/11_graph_integrity_checks.cypher
```

The seed scripts use stable IDs and `MERGE`, so they can be rerun without creating duplicate nodes or relationships.

To fully refresh the graph and run all checks in one command:

```bash
scripts/refresh-and-test.sh
```

## How To Read This Project

Start with the project in five layers:

1. **Core CDC graph**: product, formulation, recipe, material lots, equipment, sensors, CPPs, CQAs, run, deviations, batch record, and QA release.
2. **CMC/QMS governance graph**: CMC package, control strategy, validation, analytical methods, stability, SOPs, training, equipment qualification, CSV, change control, and audit trail.
3. **End-to-end conceptual model**: crystallisation through isolation, drying, milling, API handling, CDC, powder coating, coated tablet collection, and QA/CMC review.
4. **CDE registry**: critical data elements mapped to unit operations, source systems, owners, stewards, data quality rules, standards, and CTD Module 3 sections.
5. **AI-readiness layer**: CDE value domains, units of measure, representative and time-series CDE values, definition versions, approvals, provenance statements, and validation checks.

Recommended reading path:

1. [docs/beginner-handbook.md](docs/beginner-handbook.md) for the beginner-friendly explanation of the domain, graph, ontology, AI-ready data, RAG, Cypher, and the Laravel agent.
2. [docs/domain-glossary.md](docs/domain-glossary.md) for the ubiquitous language.
3. [docs/commercial-use-cases.md](docs/commercial-use-cases.md) for practical commercial, consulting, and training scenarios.
4. [docs/cdc-a4-diagram.html](docs/cdc-a4-diagram.html) for the one-page graph overview.
5. [docs/cdc-data-flow-a4.html](docs/cdc-data-flow-a4.html) for the CDC manufacturing data flow.
6. [docs/end-to-end-cdc-conceptual-data-model.md](docs/end-to-end-cdc-conceptual-data-model.md) for the crystallisation-to-coated-tablet model.
7. [docs/end-to-end-cdc-cde-catalog.md](docs/end-to-end-cdc-cde-catalog.md) for the CDE catalog.
8. [docs/end-to-end-cdc-data-model-a4.html](docs/end-to-end-cdc-data-model-a4.html) for the printable end-to-end conceptual data model.
9. [docs/ai-readiness-evidence-a4.html](docs/ai-readiness-evidence-a4.html) for the printable AI-readiness evidence pattern.
10. [docs/how-to-read-graph-answers.md](docs/how-to-read-graph-answers.md) for interpreting Neo4j Browser and agent answers.
11. [docs/ontology/cdc-ontology.md](docs/ontology/cdc-ontology.md) for the formal semantic model, class hierarchy, relationship matrix, controlled vocabularies, RDF/OWL Turtle, SHACL validation shapes, and relationship map.
12. [laravel-agent/README.md](laravel-agent/README.md) for the constrained Laravel agent CLI and API.
13. [docs/final-audit.md](docs/final-audit.md) for final graph counts, validation evidence, completed improvements, and residual limitations.
14. [docs/improvement-backlog.md](docs/improvement-backlog.md) for completed improvements and future implementation ideas.

Use the query files this way:

- `cypher/04_queries.cypher`: operational CDC manufacturing graph questions.
- `cypher/06_cmc_qms_queries.cypher`: CMC, QMS, validation, SOP, training, and audit trail questions.
- `cypher/08_end_to_end_cde_queries.cypher`: end-to-end process topology and CDE registry questions.
- `cypher/10_ai_readiness_checks.cypher`: validation checks for CDE governance, grounding, values, provenance, and graph hygiene.
- `cypher/11_graph_integrity_checks.cypher`: structural graph checks for product context, topology, genealogy, assets, QA disposition, template relationship availability, and orphan nodes.
- `cypher/12_security_agent_user.cypher`: creates the separate `cdc_agent_reader` account used by the Laravel agent.
- `scripts/refresh-and-test.sh`: full graph refresh and validation script.

Use the ontology files this way:

- `docs/ontology/cdc-ontology.md`: human-readable ontology guide.
- `docs/ontology/cdc-class-hierarchy.mmd`: Mermaid class hierarchy.
- `docs/ontology/cdc-relationship-matrix.md`: allowed subject-predicate-object relationship patterns.
- `docs/ontology/cdc-controlled-vocabularies.md`: recommended value sets.
- `docs/ontology/relationship-map.json`: machine-readable Neo4j relationship to ontology predicate mapping.
- `docs/ontology/cdc-ontology.ttl`: RDF/OWL-style ontology.
- `docs/ontology/cdc-shacl-shapes.ttl`: SHACL-style validation rules for required properties and relationships.
- `docs/rag-manifest.jsonl`: stable document chunks and retrieval metadata for RAG or agent evaluation.
- `docs/rag-manifest-readme.md`: schema and usage notes for the RAG manifest.
- `laravel-agent/resources/cdc-agent/`: approved Laravel agent questions, expected answers, and Cypher templates.

Run the deterministic Laravel agent CLI with:

```bash
cd laravel-agent
php85 artisan cdc-agent:evaluate
```

List available test questions with:

```bash
cd laravel-agent
php85 artisan cdc-agent:evaluate --list
```

The Laravel agent defaults to:

```text
Username: cdc_agent_reader
Password: cdc-agent-reader-password
```

Neo4j Community supports separate users but not server-enforced role-based read-only permissions. The Laravel agent uses `cypher-shell --access-mode read`; use Neo4j Enterprise RBAC for true least-privilege read-only enforcement.

Ask the Laravel agent API with:

```bash
cd laravel-agent
php85 artisan serve
curl -X POST http://localhost:8000/api/agent/ask \
  -H "Content-Type: application/json" \
  -d '{"question":"What does REJECTS mean?","question_id":"q013_relationship_definition"}'
```

If using [Laravel Herd](https://herd.laravel.com) as a parked site, open:

```text
http://laravel-agent.test/agent
```

Or call the API at:

```bash
curl -X POST http://laravel-agent.test/api/agent/ask \
  -H "Content-Type: application/json" \
  -d '{"question":"What does REJECTS mean?","question_id":"q013_relationship_definition"}'
```

See [laravel-agent/README.md](laravel-agent/README.md) for full Herd setup notes.

The easiest Neo4j Browser visualisation queries are:

```cypher
MATCH path = (:UnitOperation {unitOperationId: 'UO-001-CRYSTALLISATION'})-[:NEXT_OPERATION*0..11]->(:UnitOperation {unitOperationId: 'UO-012-QA-CMC-REVIEW'})
RETURN path;
```

```cypher
MATCH (cmc:CMCPackage {cmcPackageId: 'CMC-NCL-CDC-10MG-001'})
OPTIONAL MATCH operationPath = (:UnitOperation {unitOperationId: 'UO-001-CRYSTALLISATION'})-[:NEXT_OPERATION*0..11]->(:UnitOperation {unitOperationId: 'UO-012-QA-CMC-REVIEW'})
OPTIONAL MATCH cdePath = (cmc)-[:GOVERNS_CDE]->(:CriticalDataElement)-[:OBSERVED_AT]->(:UnitOperation)
OPTIONAL MATCH standardPath = (:CriticalDataElement)-[:MAPS_TO_STANDARD]->(:DataStandard)
OPTIONAL MATCH cmcPath = (:CriticalDataElement)-[:SUPPORTS_CMC_SECTION]->(:RegulatorySection)
RETURN operationPath, cdePath, standardPath, cmcPath;
```

## Model Overview

The graph is organized into five connected domains:

1. Product and process definition
2. Manufacturing assets and control strategy
3. Execution, genealogy, and quality events
4. QA and regulatory evidence
5. Data governance, CDE values, and AI-readiness evidence

## Master, Reference, And Transactional Data

This demo intentionally separates relatively stable definitions from execution evidence:

- **Master data** describes durable business entities that are governed outside any single run. In this graph, that includes `Product`, `Formulation`, `Recipe`, `Material`, `Supplier`, `ManufacturingSite`, `ManufacturingLine`, `Room`, `Equipment`, `Sensor`, `CPP`, `CQA`, and `Specification`. Most of this is seeded in `cypher/02_seed_reference_data.cypher` because it represents the product/process/equipment context required before a run can be interpreted.
- **Reference data** describes controlled vocabularies, classifications, limits, and interpretation context. In this graph, reference-data-like properties include material roles, equipment types, cleanroom classifications, supplier qualification statuses, specification types, alarm severities, deviation types, and QA decision statuses. For a larger implementation, these could be promoted from properties into explicit nodes such as `MaterialRole`, `EquipmentType`, `DeviationCategory`, or `DispositionStatus`.
- **Reference data** is also represented as explicit graph nodes for CDE domains, criticality levels, run statuses, decision statuses, deviation severities, and relationship definitions.
- **Transactional data** records what happened during execution. In this graph, that includes `ManufacturingRun`, `MaterialLot`, `SensorReading`, `Alarm`, `Deviation`, `CleaningRecord`, `CalibrationRecord`, `BatchRecord`, and `QAReleaseDecision`. The example execution evidence is seeded in `cypher/03_seed_manufacturing_run.cypher`.
- **Governance and evidence data** connects the product and run graph to CMC, QMS, ISO/GMP-inspired controls, validation, methods, stability, SOPs, training, qualification, CSV, change control, and audit trail concepts. This is seeded in `cypher/05_seed_cmc_qms_extension.cypher`.
- **CDE registry data** describes the critical data elements that flow through the end-to-end manufacturing chain. CDEs are metadata records, not raw measurements. They define the data that must be governed, sourced, quality-checked, and mapped to standards. This is seeded in `cypher/07_seed_end_to_end_cde_model.cypher`.
- **AI-readiness enrichment data** adds value domains, units, representative CDE values, time-series CDE values, definition versions, approvals, evidence documents, controlled vocabulary nodes, relationship definitions, and provenance so AI systems can distinguish definitions from observed values and cite standards context. This is seeded in `cypher/09_seed_ai_readiness_enrichment.cypher`.

The split matters architecturally: master and reference data provide the semantic frame for batch review and analytics, while transactional data provides the evidence trail. For example, a `SensorReading` is only meaningful when connected back to the `Sensor`, measured `CPP` or `CQA`, relevant `Specification`, executing `ManufacturingRun`, and ultimately the product and recipe context.

## AI-Ready Data Pattern

The AI-ready part of the model separates definitions, values, evidence, and retrieval context:

- `CriticalDataElement` is the governed definition: name, business meaning, domain, criticality, owner, steward, source system, data quality rule, CMC section, and standards mapping.
- `ValueDomain`, `UnitOfMeasure`, and `AllowedValue` describe how a value should be interpreted before an AI workflow reasons over it.
- `CDEVersion` and `CDEDefinitionApproval` show that a data definition is versioned and reviewable.
- `CDEValue` represents a demo observed or textual value for a CDE and links back to the run. Some CDE values also link to actual `SensorReading` evidence, and selected crystallisation, drying, milling, and coating CDEs have short simulated value series for trend-style questions.
- `EvidenceDocument` represents fictional document-style evidence that supports CDE values, standard mappings, batch records, QA decisions, validation evidence, and filing context.
- `CDEDomain`, `CriticalityLevel`, `RunStatus`, `DecisionStatus`, `DeviationSeverity`, and `RelationshipDefinition` make important reference data queryable as graph nodes.
- `ProvenanceStatement` provides source context for standard mappings, so an agent can cite where the standards context came from instead of treating mappings as unsupported assertions.
- `docs/rag-manifest.jsonl` lists stable documentation chunks and the questions they are intended to answer for RAG or agent testing.

The refreshed graph currently contains 25 CDE definitions, 50 CDE values, 15 value domains, 15 units of measure, 72 standard mappings, 10 provenance statements, 6 evidence documents, 15 controlled vocabulary nodes, 15 relationship definition nodes, and 2 manufacturing runs. The CDE values include 25 representative examples plus 25 simulated series observations across crystallisation, drying, milling, and coating.

The shared domain vocabulary is documented in [docs/domain-glossary.md](docs/domain-glossary.md). Use it as the ubiquitous language for architecture workshops and model reviews.

Important relationship patterns include:

```text
(Product)-[:HAS_FORMULATION]->(Formulation)-[:USES_MATERIAL]->(Material)
(Product)-[:HAS_RECIPE]->(Recipe)-[:DEFINES_STEP]->(ProcessStep)
(ManufacturingRun)-[:EXECUTES]->(Recipe)
(ManufacturingRun)-[:CONSUMES]->(MaterialLot)-[:INSTANCE_OF]->(Material)
(MaterialLot)-[:SUPPLIED_BY]->(Supplier)
(ProcessStep)-[:USES_EQUIPMENT]->(Equipment)-[:HAS_SENSOR]->(Sensor)
(Sensor)-[:MEASURES]->(CPP|CQA)
(SensorReading)-[:RECORDED_BY]->(Sensor)
(SensorReading)-[:DURING_RUN]->(ManufacturingRun)
(CPP)-[:CONTROLS]->(ProcessStep)
(CPP)-[:IMPACTS]->(CQA)-[:HAS_SPECIFICATION]->(Specification)
(ManufacturingRun)-[:HAS_DEVIATION]->(Deviation)-[:INVESTIGATES]->(Alarm)
(Alarm)-[:TRIGGERED_BY]->(SensorReading)
(ManufacturingRun)-[:HAS_BATCH_RECORD]->(BatchRecord)
(QAReleaseDecision)-[:REVIEWS]->(BatchRecord)
(QAReleaseDecision)-[:RELEASES]->(ManufacturingRun)
(QAReleaseDecision)-[:REJECTS]->(ManufacturingRun)
(RegulatoryFiling)-[:COVERS]->(Product)
(ValidationEvidence)-[:SUPPORTS]->(RegulatoryFiling)
(Product)-[:HAS_CMC_PACKAGE]->(CMCPackage)
(RegulatoryFiling)-[:SUBMITS]->(CMCPackage)
(CMCPackage)-[:INCLUDES]->(ControlStrategy|ProcessValidation|AnalyticalMethod|StabilityStudy)
(ControlStrategy)-[:CONTROLS]->(CPP)
(ControlStrategy)-[:PROTECTS]->(CQA)
(AnalyticalMethod)-[:MEASURES]->(CQA)
(SOP)-[:GOVERNS_RECIPE]->(Recipe)
(TrainingRecord)-[:COVERS_SOP]->(SOP)
(EquipmentQualification)-[:QUALIFIES]->(Equipment)
(ComputerSystemValidation)-[:VALIDATES_DATA_SOURCE]->(Sensor)
(AuditTrailEvent)-[:DOCUMENTS]->(SensorReading|Alarm|Deviation|QAReleaseDecision)
(ProcessSegment)-[:CONTAINS_OPERATION]->(UnitOperation)
(UnitOperation)-[:NEXT_OPERATION]->(UnitOperation)
(UnitOperation)-[:PRODUCES]->(IntermediateProduct)
(UnitOperation)-[:HAS_TRANSFORMATION]->(MaterialTransformation)
(CriticalDataElement)-[:OBSERVED_AT]->(UnitOperation)
(CriticalDataElement)-[:SOURCED_FROM]->(DataSourceSystem)
(CriticalDataElement)-[:HAS_DATA_QUALITY_RULE]->(DataQualityRule)
(CriticalDataElement)-[:MAPS_TO_STANDARD]->(DataStandard)
(CriticalDataElement)-[:SUPPORTS_CMC_SECTION]->(RegulatorySection)
(CriticalDataElement)-[:HAS_VALUE_DOMAIN]->(ValueDomain)
(CDEValue)-[:VALUE_OF]->(CriticalDataElement)
(CDEValue)-[:CONFORMS_TO_VALUE_DOMAIN]->(ValueDomain)
(CDEValue)-[:OBSERVED_DURING]->(ManufacturingRun)
(CDEValue)-[:DERIVED_FROM_READING]->(SensorReading)
(StandardMapping)-[:SUPPORTED_BY_PROVENANCE]->(ProvenanceStatement)
(EvidenceDocument)-[:EVIDENCES_CDE_VALUE]->(CDEValue)
(EvidenceDocument)-[:SUPPORTS_MAPPING]->(StandardMapping)
(CriticalDataElement)-[:HAS_CDE_DOMAIN]->(CDEDomain)
(CriticalDataElement)-[:HAS_CRITICALITY_LEVEL]->(CriticalityLevel)
(CMCPackage)-[:REFERENCES_RELATIONSHIP_DEFINITION]->(RelationshipDefinition)
(CMCPackage)-[:REFERENCES_STANDARD]->(DataStandard)
(CMCPackage)-[:REFERENCES_CMC_SECTION]->(RegulatorySection)
(CMCPackage)-[:HAS_DATA_OWNER]->(DataOwner)
(CMCPackage)-[:REFERENCES_UNIT]->(UnitOfMeasure)
```

## Labels

- `Product`: Commercial or development product, such as `NCL-CDC-Tablet-10mg`.
- `Formulation`: Versioned composition and dose basis for the product.
- `Recipe`: Versioned manufacturing recipe for the CDC process.
- `Material`: Material master data for API, excipients, and lubricant.
- `MaterialLot`: Physical material lots consumed by a run.
- `Supplier`: Qualified suppliers for material lots and material master data.
- `ManufacturingSite`: Facility where the process is executed.
- `ManufacturingLine`: CDC line containing rooms and equipment.
- `Room`: Manufacturing room or suite.
- `Equipment`: Feeders, blender, press, checkweigher, PAT and environmental instruments.
- `ProcessStep`: Ordered CDC process step, from API feeding to finished tablet collection.
- `ManufacturingRun`: Executed continuous manufacturing run with batch identity.
- `Sensor`: Historian or instrument source that measures CPPs or CQAs.
- `SensorReading`: Time-stamped value captured during a run.
- `CPP`: Critical process parameter, such as feed rate or compression force.
- `CQA`: Critical quality attribute, such as blend uniformity or tablet weight.
- `Specification`: Acceptance limits for CQAs.
- `Deviation`: Quality investigation record for process or data excursions.
- `Alarm`: Alarm generated from a process reading.
- `CleaningRecord`: Cleaning and line-clearance evidence.
- `CalibrationRecord`: Calibration evidence for instruments or equipment.
- `Operator`: Manufacturing, automation, or QA person participating in the record.
- `BatchRecord`: Electronic batch record summary.
- `QAReleaseDecision`: QA disposition record that releases or rejects a run.
- `RegulatoryFiling`: CMC filing or evidence package covering a product.
- `ValidationEvidence`: Validation documents supporting the filing.
- `CMCPackage`: Chemistry, Manufacturing, and Controls knowledge package for the product.
- `ControlStrategy`: Integrated material, process, analytical, and quality controls protecting CQAs.
- `ProcessValidation`: Validation package connecting recipe, run evidence, and PPQ/control strategy.
- `AnalyticalMethod`: Method used to measure or verify a CQA.
- `StabilityStudy`: Stability protocol or study monitoring product quality over time.
- `ChangeControl`: Governed assessment and approval of a proposed change.
- `RiskAssessment`: Quality risk assessment connecting CMAs, CPPs, CQAs, and controls.
- `CriticalMaterialAttribute`: Material attribute that can affect process performance or product quality.
- `SOP`: Standard operating procedure governing manufacturing, PAT, deviation, or data review activity.
- `TrainingRecord`: Evidence that an operator is trained on an SOP.
- `EquipmentQualification`: Qualification evidence for equipment fitness for intended use.
- `ComputerSystemValidation`: Validation evidence for computerized systems and data sources.
- `AuditTrailEvent`: Data integrity evidence for regulated events and decisions.
- `ProcessSegment`: Major stage of the end-to-end manufacturing flow.
- `UnitOperation`: Conceptual unit operation from crystallisation to coated tablet collection.
- `CriticalDataElement`: Governed metadata record for a critical data element.
- `DataStandard`: ICH, ISO, ISA, or CTD standard/guidance context.
- `StandardMapping`: Explicit mapping record connecting a CDE to a standard and CMC section.
- `DataSourceSystem`: System of record or source for a CDE.
- `DataOwner`: Accountable business owner for a CDE.
- `DataSteward`: Steward responsible for CDE definition and data quality.
- `DataQualityRule`: Required data quality or data integrity rule.
- `ControlPoint`: Conceptual point where process control is applied.
- `MaterialTransformation`: Material state change across a unit operation.
- `IntermediateProduct`: Intermediate material state in the end-to-end process.
- `SamplingPoint`: Location or event where material/process data is sampled.
- `RegulatorySection`: CTD Module 3 / CMC section supported by a CDE.
- `ValueDomain`: Data type, unit, and allowed-value context for a CDE.
- `UnitOfMeasure`: Controlled unit used by a value domain.
- `AllowedValue`: Controlled permissible value for a value domain.
- `CDEVersion`: Versioned CDE definition.
- `CDEDefinitionApproval`: Approval record for a CDE definition version.
- `CDEValue`: Representative observed or textual value for a CDE.
- `ProvenanceStatement`: Citation and source context supporting a standard or mapping.
- `EvidenceDocument`: Fictional document-style evidence supporting values, mappings, batch records, QA decisions, validation evidence, or filing context.
- `CDEDomain`: Controlled vocabulary for CDE domain classification.
- `CriticalityLevel`: Controlled vocabulary for CDE criticality.
- `DecisionStatus`: Controlled vocabulary for QA decision status or disposition.
- `RunStatus`: Controlled vocabulary for manufacturing run status.
- `DeviationSeverity`: Controlled vocabulary for deviation severity.
- `RelationshipDefinition`: Machine-readable mapping between Neo4j relationship types and ontology predicates.

## Example Questions

The included query file answers:

- What is the full CDC process graph for a manufacturing run?
- Which material lots and suppliers contributed to a released batch?
- Which CPPs can impact blend uniformity, tablet weight, or dissolution?
- Which readings were outside specification?
- Which alarm and readings caused a deviation?
- Which equipment and sensors were involved in a released run?
- Which validation evidence supports the product filing?
- What is the ordered CDC recipe from API feeding to tablet collection?
- Which runs were affected by a specific material lot?
- What graph-friendly query should be used for Neo4j Browser visualization?
- What CMC evidence supports the product filing?
- Which control strategy elements protect a selected CQA?
- Which SOPs, training records, audit trail events, equipment qualifications, and CSV records govern a released run?
- What is the end-to-end process path from crystallisation to powder coated tablet?
- Which CDEs are generated or used at each unit operation?
- Which CDEs support a selected CTD Module 3 section?
- Which data quality rules apply to critical CDEs?
- Which source systems and ISA-95 layers produce the CDEs?
- Which CDEs have complete AI-ready metadata, values, and provenance?
- Which standard mappings are supported by provenance?
- Which CDE values are linked to run evidence?
- Which evidence documents support a selected CDE or CDE value?
- Which run was released and which run was rejected?
- Which controlled vocabulary nodes classify a CDE?
- Which ontology predicate maps to a Neo4j relationship type?
- Does the graph pass structural integrity checks for topology, genealogy, assets, QA disposition, and orphan-node hygiene?

## Demo Data Notes

The released example run `RUN-CDC-2026-06-01-001` includes:

- A fictional product named `NCL-CDC-Tablet-10mg`; `NCL` is the NOSWAD CONSULTING LTD reference-architecture prefix, not a real medicine identifier.
- Five consumed material lots for API, MCC, lactose, croscarmellose sodium, and magnesium stearate.
- CDC process readings from feeders, blender, NIR PAT, compression force, checkweigher, and room humidity.
- One blend uniformity alarm caused by an out-of-spec NIR reading.
- One deviation investigation that considers both the NIR alarm and a humidity excursion.
- One QA release decision that releases the run after documented assessment and diversion of affected material.

The rejected example run `RUN-CDC-2026-06-02-002` includes:

- The same fictional product and CDC line context.
- The same input material lots so lot impact analysis can identify multiple affected runs.
- Persistent out-of-spec NIR blend uniformity readings and a humidity excursion.
- One critical alarm and one deviation.
- One QA rejection decision using the `REJECTS` relationship.
- Fictional evidence document context for the rejected disposition.

## Limitations

This is a reference architecture and demonstration model. It is not a validated GxP system, not an electronic batch record implementation, not a process control system, and not suitable for regulated decision-making without formal validation, security controls, audit trails, data integrity controls, change control, and quality approval.

## Commercial Use And Services

This public repository is intended to demonstrate the reference architecture and create a shared language for CDC manufacturing knowledge graphs, CDE governance, CMC evidence traceability, ontology design, and AI-ready data.

Organisations can use the public materials under the licence terms, with attribution to NOSWAD CONSULTING LTD. For client-specific or production-facing work, NOSWAD CONSULTING LTD can provide services such as:

- AI-ready manufacturing data assessments;
- CDE catalog and data governance design;
- ontology and ubiquitous-language workshops;
- Neo4j manufacturing knowledge graph proof-of-concepts;
- CMC/QMS evidence traceability architecture;
- Laravel/RAG/agent proof-of-concepts grounded in graph evidence;
- training and executive education using the reference architecture;
- client-specific extensions, integrations, and implementation roadmaps.

See [docs/commercial-use-cases.md](docs/commercial-use-cases.md) for practical use cases.

## Support This Work

This reference architecture is maintained by NOSWAD CONSULTING LTD.

If it helps your team, you can support continued public development, documentation, and example models through [GitHub Sponsors](https://github.com/sponsors/NOSWAD-CONSULTING-LTD).

Commercial support, training, workshops, and client-specific implementation services are also available from [NOSWAD CONSULTING LTD](https://noswad.co.uk).

## Licence And Attribution

Copyright (c) 2026 [NOSWAD CONSULTING LTD](https://noswad.co.uk).

This repository uses a dual licence:

- Software code: Apache License 2.0.
- Documentation, diagrams, Cypher seed data, ontology files, glossary content, conceptual models, reference architecture materials, and demo data: Creative Commons Attribution 4.0 International.

Anyone using, adapting, distributing, publishing, presenting, or commercially applying this reference architecture must credit NOSWAD CONSULTING LTD.

Suggested attribution:

```text
Based on the CDC Pharmaceutical Manufacturing Knowledge Graph Reference Architecture by NOSWAD CONSULTING LTD.
```

See [LICENSE](LICENSE), [NOTICE](NOTICE), and [CITATION.cff](CITATION.cff).
