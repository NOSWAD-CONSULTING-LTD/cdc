# Beginner Handbook For The CDC Knowledge Graph

This handbook is for someone new to the project, Neo4j, pharmaceutical manufacturing data, or AI-ready knowledge graphs. It explains the domain, the model, the files, and how to explore the graph without assuming prior knowledge.

## 1. What This Project Is

This project is a demo knowledge graph for pharmaceutical Continuous Direct Compression (CDC) manufacturing.

It models how a fictional tablet product moves from upstream drug substance processing through continuous tablet manufacture, powder coating, quality review, and regulatory evidence. The product name is `NCL-CDC-Tablet-10mg`; `NCL` is the NOSWAD CONSULTING LTD reference-architecture prefix, not a real medicine identifier.

The graph is designed for architecture discussions. It shows how manufacturing, quality, regulatory, ontology, and AI-readiness concepts can connect. It is not a validated GxP system, not a real batch record, and not a regulatory submission.

## 2. The Domain In Plain English

Pharmaceutical manufacturing needs evidence that a product was made under control. For a tablet, that means knowing:

- what product was made;
- which formulation and recipe were used;
- which material lots were consumed;
- which equipment, rooms, sensors, and operators were involved;
- which process parameters were controlled;
- which quality attributes were measured;
- whether any alarms or deviations occurred;
- how QA decided to release, reject, or quarantine the run;
- which CMC and regulatory evidence supports the product and process.

CDC means **Continuous Direct Compression**. In a CDC tablet process, powder ingredients are fed continuously, blended, lubricated, compressed into tablets, checked in process, and collected. This project also extends the view upstream and downstream:

```text
Crystallisation
-> Isolation, filtration, and washing
-> Drying
-> Milling, micronisation, and sieving
-> API intermediate handling
-> API and excipient feeding
-> Continuous blending
-> Lubricant addition
-> Tablet compression and weight control
-> Semi-continuous powder coating
-> Powder coated tablet collection
-> QA, CMC, and regulatory evidence review
```

## 3. What We Modelled

The graph has several connected areas.

**Product and process definition**

- `Product`: the fictional tablet product.
- `Formulation`: the material composition.
- `Recipe`: the manufacturing recipe.
- `ProcessStep`: CDC recipe steps such as API feeding, blending, compression, and collection.

**Materials and genealogy**

- `Material`: material master data such as API, MCC, lactose, croscarmellose sodium, and magnesium stearate.
- `MaterialLot`: actual lots consumed by a run.
- `Supplier`: supplier master data.
- `CONSUMES`, `INSTANCE_OF`, and `SUPPLIED_BY` relationships trace a finished run back to input lots and suppliers.

**Assets and instrumentation**

- `ManufacturingSite`, `ManufacturingLine`, and `Room`: where manufacturing happens.
- `Equipment`: feeders, blender, tablet press, checkweigher, and sensors.
- `Sensor`: instruments that record process and quality data.
- `SensorReading`: actual readings during a run.

**Control strategy**

- `CPP`: Critical Process Parameter, such as API feed rate or compression force.
- `CQA`: Critical Quality Attribute, such as blend uniformity or tablet weight.
- `Specification`: target, lower limit, and upper limit context.
- CPPs can impact CQAs, and sensors can measure CPPs or CQAs.

**Execution and quality**

- `ManufacturingRun`: an executed run.
- `Alarm`: an alarm triggered by a bad or warning reading.
- `Deviation`: an investigation into an event.
- `BatchRecord`: the electronic batch record context.
- `QAReleaseDecision`: QA release or rejection decision.

The demo now includes two runs:

- `RUN-CDC-2026-06-01-001`: released after a closed deviation.
- `RUN-CDC-2026-06-02-002`: rejected/quarantined after persistent blend uniformity failure.

**CMC, QMS, and regulatory evidence**

- `CMCPackage`: Chemistry, Manufacturing, and Controls package context.
- `RegulatoryFiling`: fictional filing context.
- `ValidationEvidence`: validation and method evidence.
- `SOP`, `TrainingRecord`, `AuditTrailEvent`, `ChangeControl`, and related QMS nodes.
- `EvidenceDocument`: explicit demo document records supporting CDE values, mappings, batch records, and QA decisions.

**Critical Data Elements**

- `CriticalDataElement`: governed data definitions. These are metadata, not measurements.
- `CDEValue`: observed or textual example values for a CDE.
- `ValueDomain`, `UnitOfMeasure`, and `AllowedValue`: how values should be interpreted.
- `DataOwner`, `DataSteward`, `DataQualityRule`, and `DataSourceSystem`: governance context.

## 4. Master, Reference, Transactional, Governance, And Evidence Data

A useful way to read the graph is to ask what type of data a node represents.

**Master data** is relatively stable business context. Examples: `Product`, `Material`, `Supplier`, `Equipment`, `Sensor`, `Recipe`.

**Reference data** is controlled vocabulary or interpretation context. Examples: `ValueDomain`, `UnitOfMeasure`, `CDEDomain`, `CriticalityLevel`, `RunStatus`, `DecisionStatus`.

**Transactional data** records what happened. Examples: `ManufacturingRun`, `SensorReading`, `Alarm`, `Deviation`, `BatchRecord`, `QAReleaseDecision`.

**Governance data** says who owns data, where it comes from, which rules apply, and which standards it maps to. Examples: `DataOwner`, `DataSteward`, `DataQualityRule`, `StandardMapping`.

**Evidence data** supports conclusions. Examples: `EvidenceDocument`, `ValidationEvidence`, `ProvenanceStatement`, `AuditTrailEvent`.

## 5. Graph Basics

Neo4j stores data as a graph.

A **node** is a thing, such as a product, run, material lot, sensor, CDE, or document.

A **label** classifies a node. A node with label `ManufacturingRun` is a manufacturing run.

A **relationship** connects two nodes. For example:

```text
(ManufacturingRun)-[:CONSUMES]->(MaterialLot)
```

A **property** is a named value on a node or relationship. For example, a run has `runId`, `status`, `batchNumber`, `startTime`, and `disposition`.

A **path** is a chain of connected nodes and relationships. Paths are how the graph answers traceability questions.

## 6. Knowledge Graph Basics

A knowledge graph is more than connected records. It adds meaning:

- stable IDs;
- named relationship types;
- domain vocabulary;
- governed definitions;
- provenance;
- validation rules;
- links between operations, data, quality, and evidence.

This matters because pharma questions are often relationship questions:

- Which lots contributed to this run?
- Which supplier supplied a material lot?
- Which sensor triggered the deviation?
- Which CPPs impact this CQA?
- Which CDEs support this CTD Module 3 section?
- Which evidence supports this AI answer?

## 7. Cypher Basics

Cypher is Neo4j's query language.

Find one run:

```cypher
MATCH (run:ManufacturingRun {runId: 'RUN-CDC-2026-06-01-001'})
RETURN run;
```

Find material lots consumed by a run:

```cypher
MATCH (run:ManufacturingRun {runId: 'RUN-CDC-2026-06-01-001'})
MATCH (run)-[:CONSUMES]->(lot:MaterialLot)-[:INSTANCE_OF]->(material:Material)
RETURN run.runId, lot.lotNumber, material.name;
```

Return a graph path for Neo4j Browser visualisation:

```cypher
MATCH path = (:ManufacturingRun {runId: 'RUN-CDC-2026-06-01-001'})-[:CONSUMES]->(:MaterialLot)-[:INSTANCE_OF]->(:Material)
RETURN path;
```

Find readings outside limits:

```cypher
MATCH (reading:SensorReading)
WHERE reading.value < reading.lowerLimit OR reading.value > reading.upperLimit
RETURN reading.readingId, reading.value, reading.unit, reading.status;
```

## 8. Conceptual, Semantic, Logical, Physical, And Ontology Models

These words often get mixed together, but they serve different purposes.

The simple stack is:

```text
Glossary / ubiquitous language
-> conceptual data model
-> semantic data model
-> logical model
-> ontology
-> physical Neo4j graph
-> RAG / agent interpretation
```

**Conceptual model**

This explains the business concepts and how they relate, without worrying too much about database implementation. In this repo, see `docs/end-to-end-cdc-conceptual-data-model.md`.

**Semantic data model**

This explains what the concepts and relationships mean across manufacturing, quality, CMC, governance, and AI/RAG interpretation. It is the bridge between plain business language and the formal ontology. In this repo, see `docs/semantic-data-model.md`.

**Logical model**

This starts to define entities, attributes, relationships, identifiers, and rules. The CDE catalog and ontology relationship matrix are closer to logical model artifacts.

**Physical model**

This is what is actually implemented in Neo4j: labels, relationship types, constraints, indexes, and Cypher seed files.

**Ontology**

An ontology defines domain meaning more formally: classes, predicates, allowed relationships, and rules. In this repo:

- `docs/ontology/cdc-ontology.md` is the human-readable ontology guide.
- `docs/ontology/cdc-ontology.ttl` is an RDF/OWL-style ontology file.
- `docs/ontology/cdc-shacl-shapes.ttl` shows SHACL-style validation rules.
- `docs/ontology/relationship-map.json` maps Neo4j relationship types to ontology predicates.

## 9. Semantics

Semantics means meaning. In this graph, semantics are expressed through:

- labels such as `CDEValue` versus `CriticalDataElement`;
- relationship names such as `VALUE_OF`, `CONFORMS_TO_VALUE_DOMAIN`, and `SUPPORTED_BY_PROVENANCE`;
- value domains and units;
- controlled vocabulary nodes;
- ontology predicates;
- glossary definitions.

The distinction between `CriticalDataElement` and `CDEValue` is especially important:

```text
CriticalDataElement = definition of data that matters
CDEValue = observed or textual value for a specific context
```

An AI answer should not treat a definition as if it were a measurement.

## 10. AI-Ready Data

AI-ready data is data that an AI system can use with less guessing.

In this project, that means:

- stable IDs on major nodes;
- clear domain definitions;
- data owners and stewards;
- source systems;
- value domains and units;
- data quality rules;
- provenance statements;
- evidence documents;
- approved Cypher templates;
- validation checks;
- documentation chunks for retrieval.

The goal is not to make the AI "magically know pharma." The goal is to give it enough structure to answer from evidence and say where the evidence came from.

## 11. RAG And The Manifest

RAG means **Retrieval-Augmented Generation**.

Instead of asking an AI model to answer from memory, a RAG workflow retrieves relevant project documents first, then asks the model to answer using those documents and graph query results.

`docs/rag-manifest.jsonl` is a manifest of useful retrieval chunks. JSONL means **JSON Lines**: one JSON object per line.

Each manifest row says:

- which file to retrieve;
- what it is about;
- which questions it helps answer;
- which tags describe it;
- how important it is for retrieval.

The manifest is not a regulatory source of truth. It is a navigation aid for agents and humans.

## 12. Agent Harnesses

The project has a deterministic Laravel agent in `laravel-agent/`.

It does not let the agent generate arbitrary Cypher. Instead, it uses approved templates from `laravel-agent/resources/cdc-agent/query_templates.json`.

The flow is:

```text
Question
-> approved template ID
-> bound Cypher query
-> Neo4j rows
-> grounded answer
-> expected-answer checks
```

This tests whether an AI-style workflow can answer useful questions without inventing unsupported claims.

## 13. How To Explore The Project

Start here:

1. Read `README.md`.
2. Read this handbook.
3. Open `docs/domain-glossary.md` for vocabulary.
4. Open `docs/cdc-a4-diagram.html` for the core graph diagram.
5. Open `docs/end-to-end-cdc-data-model-a4.html` for the broader process model.
6. Use Neo4j Browser at `http://localhost:7474/browser/`.
7. Run the sample queries in `cypher/04_queries.cypher`, `cypher/08_end_to_end_cde_queries.cypher`, and `cypher/10_ai_readiness_checks.cypher`.

Neo4j Browser login:

```text
Username: neo4j
Password: cdc-demo-password
Database: neo4j
```

Agent user:

```text
Username: cdc_agent_reader
Password: cdc-agent-reader-password
```

## 14. How To Run Everything

Start Neo4j:

```bash
docker compose up -d
```

Refresh and test everything:

```bash
scripts/refresh-and-test.sh
```

Run the Laravel agent checks:

```bash
cd laravel-agent
php85 artisan cdc-agent:evaluate
```

Ask the Laravel agent API:

```bash
cd laravel-agent
php85 artisan serve
curl -X POST http://localhost:8000/api/agent/ask \
  -H "Content-Type: application/json" \
  -d '{"question":"What does REJECTS mean?","question_id":"q013_relationship_definition"}'
```

If you are using [Laravel Herd](https://herd.laravel.com) and the `Herd` folder is parked, open the browser UI at:

```text
http://laravel-agent.test/agent
```

The equivalent Herd API URL is:

```text
http://laravel-agent.test/api/agent/ask
```

## 15. What Not To Assume

Do not assume:

- this is a real medicine;
- this is a complete product control strategy;
- this is validated GxP software;
- the CMC package is complete;
- all real manufacturing data sources are represented;
- Neo4j Community enforces true read-only RBAC.

Use this project as a reference architecture and learning model.

## 16. Useful Questions To Ask The Graph

- Which material lots and suppliers contributed to a run?
- Which run was released and which run was rejected?
- Which readings were out of specification?
- Which alarm caused a deviation?
- Which CPPs impact a CQA?
- Which CDEs support CTD 3.2.P.3.4?
- Which evidence documents support a CDE value?
- Which ontology predicate maps to a Neo4j relationship?
- Which documents should a RAG agent retrieve for a question?
