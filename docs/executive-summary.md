# Executive Summary: CDC Manufacturing Knowledge Graph Reference Architecture

This document explains the reference architecture for senior stakeholders who need to understand the business value, operating model, and strategic relevance without needing to read Cypher, Neo4j internals, or ontology files first.

The short version: this project shows how pharmaceutical manufacturing, quality, regulatory, and data governance information can be connected into an evidence-based knowledge graph. That connected graph can support traceability, CMC evidence management, critical data element governance, and controlled AI-assisted analysis.

## What This Is

This is a public reference architecture for a fictional Continuous Direct Compression (CDC) pharmaceutical tablet product called `NCL-CDC-Tablet-10mg`.

It models how data and evidence flow across a manufacturing process, from upstream crystallisation through continuous tablet manufacture and semi-continuous powder coating. It also shows how the same data can be connected to quality review, regulatory evidence, ontology, standards, and an AI-assisted question-answering layer.

It is not a production system. It is a production-inspired demonstration model intended to make complex manufacturing data architecture easier to discuss, test, and explain.

## Why It Matters

Many regulated manufacturing organisations have the same structural problem: important knowledge is spread across MES, LIMS, QMS, ERP, historians, spreadsheets, documents, data catalogs, and regulatory systems.

Each system may be valuable on its own, but the highest-value questions often cut across systems:

- Which material lots contributed to this released or rejected run?
- Which supplier, equipment, sensor, or process step was involved?
- Which process parameter affected a quality attribute?
- Which deviation, alarm, or reading supports a QA decision?
- Which CDEs support a CMC section or regulatory submission?
- Which evidence should an AI assistant cite before giving an answer?

A knowledge graph is useful because it makes those connections explicit. It does not replace source systems. It links them into a shared context that humans, governance teams, and AI-assisted tools can inspect.

## Executive Value Flow

The diagram below shows the business-level flow. Source systems continue to own operational records. The knowledge graph connects selected records, definitions, and evidence so that users and AI-assisted tools can answer cross-functional questions with traceable support.

```mermaid
flowchart LR
    sources["Operational And Governance Sources<br/>MES, LIMS, QMS, ERP, historian,<br/>documents, data catalog"]
    graph["Manufacturing Knowledge Graph<br/>Product, process, lots, equipment,<br/>readings, CDEs, quality, evidence"]
    context["Shared Meaning<br/>Glossary, semantic model,<br/>ontology, standards, value domains"]
    evidence["Traceable Evidence<br/>Batch records, deviations,<br/>QA decisions, validation, CMC support"]
    decisions["Better Decisions<br/>Impact assessment, batch review,<br/>regulatory readiness, AI-assisted analysis"]

    sources --> graph
    context --> graph
    graph --> evidence
    evidence --> decisions
    graph --> decisions
```

## What The Reference Architecture Demonstrates

The project demonstrates five connected capabilities.

| Capability | What It Means For Executives |
| --- | --- |
| Manufacturing traceability | The organisation can trace from a product or run back to material lots, suppliers, equipment, sensors, and process evidence. |
| Quality and CMC evidence | Quality events, batch records, validation evidence, control strategy, and regulatory context can be connected rather than treated as isolated documents. |
| Critical data element governance | Important data elements can be defined, owned, sourced, quality-checked, mapped to standards, and linked to observed values. |
| Semantic alignment | Business terms, data models, ontology, graph labels, and relationship definitions can be aligned into one shared language. |
| AI-assisted delivery | AI tools can be constrained to approved questions, approved graph queries, retrievable documents, and evidence-grounded answers. |

## Capability Map

The reference architecture is deliberately broader than a database demo. It connects business architecture, data architecture, quality architecture, and AI-assisted delivery.

```mermaid
flowchart TD
    exec["Executive Outcomes<br/>Faster understanding, better traceability,<br/>clearer evidence, safer AI adoption"]

    trace["Traceability<br/>Product, batch, lots,<br/>supplier, equipment, sensor"]
    quality["Quality And Regulatory<br/>Deviation, alarm, batch record,<br/>QA disposition, CMC evidence"]
    data["Data Governance<br/>CDEs, owners, stewards,<br/>quality rules, source systems"]
    semantics["Shared Meaning<br/>Glossary, semantic model,<br/>ontology, standards mapping"]
    ai["AI-Assisted Analysis<br/>RAG manifest, approved Cypher,<br/>Laravel agent, cited evidence"]

    graph["Neo4j Knowledge Graph<br/>Connected manufacturing and evidence layer"]

    trace --> graph
    quality --> graph
    data --> graph
    semantics --> graph
    ai --> graph
    graph --> exec
```

## What Makes This Different From A Dashboard

A dashboard usually shows selected metrics. A knowledge graph explains how facts relate.

For example, a dashboard might show that a batch was rejected. The graph can connect that rejection to:

- the manufacturing run;
- the batch record reviewed by QA;
- the alarm and sensor readings that triggered investigation;
- the material lots consumed;
- the equipment, room, sensors, and recipe involved;
- the CQA affected;
- the CDEs and evidence documents that support interpretation.

That difference matters for root cause analysis, impact assessment, audit readiness, and AI-assisted answers.

## What Makes This Different From A Document Repository

A document repository stores documents. A knowledge graph connects document evidence to the things those documents support.

In this reference architecture, evidence can support:

- a CDE value;
- a standard mapping;
- a batch record;
- a QA release or rejection decision;
- validation evidence;
- regulatory filing context.

This is important because AI-assisted tools should not simply retrieve plausible text. They should be able to point to the graph evidence and documents that support an answer.

## Why The Modelling Work Is Necessary

The modelling work is not documentation for its own sake. It is the work needed to make manufacturing data understandable, governable, reusable, and safe for AI-assisted use.

In many organisations, teams already have data, documents, reports, dashboards, and systems. The problem is that the meaning is often implicit:

- one team may define a batch, lot, deviation, parameter, or data element differently from another;
- source systems may use different IDs, units, statuses, and naming conventions;
- regulatory evidence may be held in documents but not connected to the process facts it supports;
- data ownership and quality expectations may be unclear;
- AI tools may retrieve text without understanding whether it is a definition, an observation, a decision, or supporting evidence.

The modelling artifacts make those assumptions explicit. They create a shared structure that allows people, systems, and AI-assisted tools to reason over the same meaning.

Without this modelling work, the organisation may still be able to build dashboards or prototypes, but the result is likely to be fragile: hard to audit, hard to scale, hard to govern, and risky to use for evidence-based AI.

## Why Each Artifact Is Important

Each artifact exists because it answers a different executive, business, architecture, or delivery question. Removing one of them creates a gap.

| Artifact | Why It Matters |
| --- | --- |
| Executive summary | Gives sponsors and decision-makers a plain-English view of value, scope, risk, and next steps. |
| Beginner handbook | Helps new stakeholders understand the domain quickly without needing prior graph, pharma, or AI knowledge. |
| Domain glossary | Creates a ubiquitous language so teams can agree what terms such as CDE, CPP, CQA, batch, lot, and evidence mean. |
| Conceptual model | Shows the business process from crystallisation to coated tablet before technology choices dominate the discussion. |
| Semantic data model | Explains the business meaning of concepts and relationships so the graph is not just connected data, but interpretable knowledge. |
| Logical data model | Defines entities, identifiers, attributes, and rules so implementation teams know what must be represented consistently. |
| Canonical data model | Provides common exchange objects so source-system differences do not leak directly into every integration and graph design. |
| Information architecture model | Clarifies information domains, ownership, stewardship, lifecycle, and navigation so the model can be governed. |
| Integration model | Explains how MES, LIMS, QMS, ERP, historians, documents, Neo4j, and the agent layer could fit together. |
| Provenance and evidence model | Shows how values, mappings, decisions, and AI answers can be traced back to supporting evidence. |
| Ontology and relationship matrix | Formalise meaning as classes, relationships, vocabularies, and constraints so humans and machines use the same interpretation. |
| Controlled vocabularies | Reduce ambiguity in statuses, classifications, criticality, severity, units, and data domains. |
| Cypher constraints and seed scripts | Turn the architecture into a working graph that can be inspected, queried, refreshed, and tested. |
| Query library | Shows the real questions the graph can answer and provides reusable examples for workshops and validation. |
| RAG manifest | Tells an AI-assisted workflow which documents are retrievable, what they are useful for, and how they should be ranked. |
| Laravel agent | Demonstrates a constrained agent pattern using approved questions, approved Cypher, graph evidence, and document retrieval. |
| Validation and integrity checks | Provide confidence that the demo graph remains coherent as the model evolves. |

The key point for executives: the artifacts are not separate deliverables competing for attention. They are layers of assurance. Together they help an organisation move from disconnected records to explainable, governed, AI-ready manufacturing knowledge.

## Strategic Use Cases

This reference architecture can support conversations about:

- AI-assisted manufacturing and quality review;
- CMC and regulatory evidence traceability;
- critical data element governance;
- process genealogy and batch impact assessment;
- ontology and semantic data modelling;
- graph-based RAG and agent design;
- data product strategy for regulated manufacturing;
- platform architecture across MES, LIMS, QMS, ERP, historians, and document systems.

## What The Models Are For

The architecture contains several model types because different audiences need different levels of detail.

| Model | Executive Interpretation |
| --- | --- |
| Glossary | Shared language so teams stop using the same words differently. |
| Conceptual model | Business view of the process from crystallisation to coated tablet. |
| Semantic data model | Meaning of the concepts and relationships across manufacturing, quality, regulatory, and AI contexts. |
| Logical and canonical models | How the concepts become consistent data structures and exchange objects. |
| Information architecture model | Who owns information, where it lives, and how it should be governed. |
| Integration model | How source systems could feed the graph and agent layer. |
| Provenance and evidence model | How answers, decisions, and values can be traced to support. |
| Ontology | Formal machine-readable meaning, classes, relationships, and constraints. |
| Neo4j graph | The working connected data implementation used for demonstration and queries. |
| Laravel agent | A constrained AI-style interface that uses approved questions, approved Cypher, and retrievable documentation. |

## What Decisions This Can Help With

Executives and senior leaders can use this reference architecture to explore:

- whether graph technology is useful for manufacturing traceability and evidence management;
- where source-system integration gaps exist;
- which CDEs need clearer ownership, definitions, or quality rules;
- how ontology and semantic modelling could reduce ambiguity;
- how to introduce AI-assisted delivery without allowing uncontrolled answers;
- what a phased proof of concept could look like before enterprise rollout.

## What This Is Not

This project is deliberately safe demo material.

It is not:

- a validated GxP system;
- an electronic batch record implementation;
- a process control system;
- a regulatory submission;
- a real product or real batch;
- a replacement for MES, LIMS, QMS, ERP, historians, document management, or regulatory systems.

Any production use would need formal validation, security controls, audit trail design, data integrity controls, change control, role-based access control, operational support, and quality approval.

## Recommended Executive Reading Path

Start with this document, then read:

1. [Beginner handbook](beginner-handbook.md) for a plain-English explanation of the domain and core concepts.
2. [Commercial use cases](commercial-use-cases.md) for practical ways this reference architecture can support consulting, workshops, and proof-of-concepts.
3. [Semantic data model](semantic-data-model.md) for how the different model layers fit together.
4. [Provenance and evidence model](provenance-evidence-model.md) for how evidence-grounded answers work.
5. [CDC data flow diagram](cdc-data-flow-diagram.md) for a more detailed data-flow view.

## Suggested Next Steps

For an organisation considering this pattern, the pragmatic next steps are:

1. Select one high-value traceability or evidence question.
2. Identify the source systems and documents needed to answer it.
3. Define the core terms, CDEs, owners, and evidence paths.
4. Build a small graph proof of concept using non-production or masked data.
5. Test whether users can answer the question faster, with clearer evidence.
6. Only then decide whether to expand into a wider data product, ontology, or AI-assisted delivery programme.
