# End-To-End CDC Conceptual Data Model

This document extends the CDC Neo4j demo from tablet direct compression into an end-to-end manufacturing data architecture from drug substance crystallisation to semi-continuous powder coated tablet collection.

It is a conceptual model for architecture discussion. It is not a validated process description, not a regulatory filing, and not a substitute for process-specific scientific justification.

## Scope

The model covers this production-inspired flow:

```text
Crystallisation
-> isolation / filtration / washing
-> drying
-> milling / micronisation / sieving
-> API intermediate handling
-> API and excipient feeding
-> continuous blending
-> lubricant addition
-> tablet compression
-> in-process tablet control
-> semi-continuous powder coating
-> coated tablet collection
-> QA / CMC / regulatory evidence
```

The goal is to identify **Critical Data Elements (CDEs)** and connect each CDE to:

- the unit operation where it is generated or used,
- the manufacturing concept it describes,
- the source system of record,
- the data owner and steward,
- the applicable data quality rule,
- the CMC/ISO/ISA/ICH standard context,
- the regulatory CTD Module 3 section it supports.

## Conceptual Layers

### 1. Process Topology

`ProcessSegment` groups the manufacturing flow:

- Drug substance formation and isolation
- API particle engineering
- Drug product continuous direct compression
- Semi-continuous powder coating
- Quality and regulatory evidence

`UnitOperation` represents each process stage. Unit operations are ordered with `NEXT_OPERATION` relationships and connected to existing CDC `ProcessStep` nodes where the unit operation overlaps the seeded tablet process.

### 2. Material Transformation

`MaterialTransformation` captures the change in material state:

```text
Solution -> Crystalline slurry -> Wet cake -> Dried API -> Milled API -> Blend -> Core tablet -> Powder coated tablet
```

`IntermediateProduct` represents the material state available for genealogy, hold-time, sampling, and release decisions.

### 3. Critical Data Elements

`CriticalDataElement` is the metadata object for a governed data element. It is not a reading itself. It describes the data that must be captured, interpreted, governed, and mapped to standards.

Example:

```text
CDE: Crystallisation temperature
Unit operation: Crystallisation
Domain: CPP
Source system: Crystalliser PLC / historian
Quality rule: range, unit, timestamp, completeness
CMC support: Module 3.2.S.2.2 process description and 3.2.S.2.4 controls
Standards context: ICH Q13, ICH Q11, ISA-95, ISO/IEC 11179
```

### 4. Source Systems

`DataSourceSystem` captures where CDE values originate:

- DCS/PLC
- Process historian
- PAT platform
- LIMS
- MES/electronic batch record
- QMS
- ERP/material management
- Environmental monitoring system

### 5. Governance

`DataOwner` and `DataSteward` make accountability explicit. `DataQualityRule` represents required checks such as completeness, uniqueness, range conformance, unit conformance, timestamp integrity, and ALCOA+ review relevance.

### 6. Standards And Regulatory Mapping

`DataStandard` represents a standard, guidance, or architecture framework. `StandardMapping` records why a CDE maps to a standard or regulatory section.

`EvidenceDocument` represents fictional document-style evidence that supports CDE values, standard mappings, batch records, QA decisions, validation evidence, or filing context. It gives an AI or reviewer a document-level evidence anchor rather than only a graph relationship.

Controlled vocabulary nodes such as `CDEDomain`, `CriticalityLevel`, `RunStatus`, `DecisionStatus`, and `DeviationSeverity` make important classifications queryable and governable instead of leaving them only as string properties.

Examples:

- ICH Q13: continuous manufacturing of drug substances and drug products.
- ICH Q8/Q9/Q10/Q11/Q12/Q14: pharmaceutical development, quality risk management, pharmaceutical quality system, drug substance development, lifecycle/change management, analytical procedure development.
- CTD Module 3 / ICH M4Q: CMC quality structure.
- ISO/IEC 11179: metadata registry and data element definition practice.
- ISO 14644: cleanroom and controlled environment context.
- ISO 22400: manufacturing operations KPIs.
- ISA-95 / IEC 62264: enterprise-control system integration and hierarchy.

## Core Relationships

```text
(ProcessSegment)-[:CONTAINS_OPERATION]->(UnitOperation)
(UnitOperation)-[:NEXT_OPERATION]->(UnitOperation)
(UnitOperation)-[:PRODUCES]->(IntermediateProduct)
(UnitOperation)-[:HAS_TRANSFORMATION]->(MaterialTransformation)
(CriticalDataElement)-[:OBSERVED_AT]->(UnitOperation)
(CriticalDataElement)-[:DESCRIBES]->(CPP|CQA|CriticalMaterialAttribute|MaterialLot|Equipment|Sensor|IntermediateProduct)
(CriticalDataElement)-[:SOURCED_FROM]->(DataSourceSystem)
(CriticalDataElement)-[:HAS_DATA_QUALITY_RULE]->(DataQualityRule)
(CriticalDataElement)-[:HAS_OWNER]->(DataOwner)
(CriticalDataElement)-[:HAS_STEWARD]->(DataSteward)
(CriticalDataElement)-[:MAPS_TO_STANDARD]->(DataStandard)
(CriticalDataElement)-[:SUPPORTS_CMC_SECTION]->(RegulatorySection)
(CriticalDataElement)-[:HAS_VALUE_DOMAIN]->(ValueDomain)
(CDEValue)-[:VALUE_OF]->(CriticalDataElement)
(CDEValue)-[:OBSERVED_DURING]->(ManufacturingRun)
(CDEValue)-[:DERIVED_FROM_READING]->(SensorReading)
(CDEVersion)-[:VERSION_OF]->(CriticalDataElement)
(CDEDefinitionApproval)-[:APPROVES]->(CDEVersion)
(StandardMapping)-[:MAPS_CDE]->(CriticalDataElement)
(StandardMapping)-[:TO_STANDARD]->(DataStandard)
(StandardMapping)-[:TO_REGULATORY_SECTION]->(RegulatorySection)
(StandardMapping)-[:SUPPORTED_BY_PROVENANCE]->(ProvenanceStatement)
```

## AI Interpretation Notes

For AI or agent workflows, interpret `CriticalDataElement` as metadata and `CDEValue` as example run evidence. Do not treat a CDE definition as if it were a measured result. A measured result should resolve through:

```text
CDEValue -> CriticalDataElement -> ValueDomain -> UnitOfMeasure
CDEValue -> ManufacturingRun -> BatchRecord -> QAReleaseDecision
CDEValue -> SensorReading through DERIVED_FROM_READING, where direct sensor evidence exists
CriticalDataElement -> StandardMapping -> ProvenanceStatement
EvidenceDocument -> CDEValue / StandardMapping / QAReleaseDecision
CriticalDataElement -> CDEDomain / CriticalityLevel
```

This structure lets an AI workflow answer questions with traceable context: what the data element means, where it came from, whether the value conforms to its domain, which run it belongs to, and which standard or CMC section supports the interpretation.

## Sources Used For Standards Context

- ICH Q13 continuous manufacturing guidance, FDA: https://www.fda.gov/regulatory-information/search-fda-guidance-documents/q13-continuous-manufacturing-drug-substances-and-drug-products
- ICH CTD overview, ICH: https://admin.ich.org/page/ctd
- ICH Q14 analytical procedure development, FDA: https://www.fda.gov/regulatory-information/search-fda-guidance-documents/q14-analytical-procedure-development
- ISO/IEC 11179 metadata registry framework, ISO: https://www.iso.org/standard/78914.html
- ISO/IEC 11179 registry conceptual model, ISO: https://www.iso.org/standard/78915.html
- ISO 14644-1 cleanroom classification, ISO: https://www.iso.org/standard/53394.html
- ISO 22400-1 manufacturing operations KPIs, ISO: https://www.iso.org/standard/56847.html
- ISA-95 / IEC 62264 enterprise-control system integration, ISA: https://www.isa.org/standards-and-publications/isa-standards/isa-95-standard
