# End-To-End CDC Critical Data Element Catalog

This catalog lists production-inspired Critical Data Elements (CDEs) from crystallisation through semi-continuous powder coating.

The catalog is broader than the seeded Neo4j demo. It is intended as an architecture discussion catalog. The current graph seeds a representative governed subset of 25 CDEs, with value domains, definition versions, approvals, representative values, selected time-series values, source systems, quality rules, standards mappings, and provenance.

`Criticality` values:

- `Critical`: needed to establish product quality, process control, genealogy, disposition, CMC evidence, or data integrity.
- `Important`: useful for interpretation, investigation, continued process verification, or operational analytics.

## Seeded CDE Subset In Neo4j

These are the 25 CDE definitions loaded by `cypher/07_seed_end_to_end_cde_model.cypher` and enriched by `cypher/09_seed_ai_readiness_enrichment.cypher`. The enrichment seed currently loads 50 `CDEValue` records: one representative value for every seeded CDE and additional simulated series values for selected crystallisation, drying, milling, and coating CDEs.

| CDE ID | Name | Domain | Criticality | Unit Operation | Value Domain |
| --- | --- | --- | --- | --- | --- |
| `CDE-API-HOLD-TIME` | API intermediate hold time | Genealogy/QMS | Critical | API intermediate handling | Hours value domain |
| `CDE-CDC-API-FEED-RATE` | API feed rate | CPP | Critical | API and excipient feeding | Mass flow value domain |
| `CDE-CDC-BLEND-NIR` | Inline NIR blend uniformity | CQA/PAT | Critical | Continuous blending | Numeric percent value domain |
| `CDE-CDC-COMPRESSION-FORCE` | Compression force | CPP | Critical | Tablet compression and weight control | Force value domain |
| `CDE-CDC-LUB-FEED-RATE` | Lubricant feed rate | CPP | Critical | Lubricant addition | Mass flow value domain |
| `CDE-CDC-TABLET-WEIGHT` | Tablet weight | CQA/IPC | Critical | Tablet compression and weight control | Tablet mass value domain |
| `CDE-CMC-SECTION-MAPPING` | CMC section mapping | Regulatory metadata | Important | QA, CMC, and regulatory evidence review | Regulatory section value domain |
| `CDE-COAT-FEED-RATE` | Coating powder feed rate | CPP | Critical | Semi-continuous powder coating | Mass flow value domain |
| `CDE-COAT-POWDER-LOT` | Coating powder lot ID | Genealogy | Critical | Semi-continuous powder coating | Identifier value domain |
| `CDE-COAT-RH` | Coating room relative humidity | CPP | Critical | Semi-continuous powder coating | Relative humidity value domain |
| `CDE-COAT-UNIFORMITY` | Coating uniformity | CQA | Critical | Semi-continuous powder coating | Numeric percent value domain |
| `CDE-COAT-WEIGHT-GAIN` | Coating weight gain | CQA/IPC | Critical | Semi-continuous powder coating | Numeric percent value domain |
| `CDE-COATED-CONTAINER-ID` | Powder coated tablet container ID | Genealogy | Critical | Powder coated tablet collection | Identifier value domain |
| `CDE-CRYST-POLYMORPH` | Polymorphic form | CQA | Critical | Crystallisation | Identifier value domain |
| `CDE-CRYST-PSD` | Crystal size distribution | CQA/CMA | Critical | Crystallisation | Particle size value domain |
| `CDE-CRYST-SEED-LOT` | Seed lot ID | Genealogy/CMA | Critical | Crystallisation | Identifier value domain |
| `CDE-CRYST-SOLVENT-COMP` | Solvent composition | CPP/CMA | Critical | Crystallisation | Numeric percent w/w value domain |
| `CDE-CRYST-SUPERSAT` | Supersaturation | CPP | Critical | Crystallisation | Numeric percent value domain |
| `CDE-DRY-LOD-ENDPOINT` | Loss on drying endpoint | CQA/IPC | Critical | Drying | Numeric percent value domain |
| `CDE-DRY-RESIDUAL-SOLVENT` | Residual solvent result | CQA | Critical | Drying | Numeric percent value domain |
| `CDE-ISO-WASH-VOLUME` | Wash solvent volume | CPP | Critical | Isolation, filtration, and washing | Mass value domain |
| `CDE-ISO-WET-CAKE-MASS` | Wet cake mass | Genealogy | Critical | Isolation, filtration, and washing | Mass value domain |
| `CDE-MILL-API-PSD` | Milled API particle size distribution | CMA | Critical | Milling, micronisation, and sieving | Particle size value domain |
| `CDE-MILL-FEED-RATE` | Feed rate to mill | CPP | Critical | Milling, micronisation, and sieving | Mass flow value domain |
| `CDE-QA-DISPOSITION` | QA disposition decision | Disposition | Critical | QA, CMC, and regulatory evidence review | QA disposition value domain |

## Crystallisation

| CDE | Domain | Criticality | Why It Matters |
| --- | --- | --- | --- |
| Crystallisation batch/stream ID | Genealogy | Critical | Anchors material genealogy from drug substance formation onward. |
| Solvent composition | CPP/CMA | Critical | Affects solubility, impurity rejection, crystal habit, and downstream drying. |
| API concentration | CPP | Critical | Drives supersaturation and crystallisation kinetics. |
| Supersaturation | CPP | Critical | Core control variable for nucleation and growth. |
| Seed lot ID | Genealogy/CMA | Critical | Connects seed material quality to crystal attributes. |
| Seed loading | CPP | Critical | Influences nucleation, crystal size distribution, and batch consistency. |
| Crystallisation temperature | CPP | Critical | Affects solubility, growth, impurity profile, and form. |
| Cooling rate | CPP | Critical | Influences nucleation rate and crystal size distribution. |
| Agitation speed | CPP | Important | Affects mixing, heat transfer, and crystal breakage. |
| Residence time | CPP | Critical | Relevant for continuous or semi-continuous crystallisation control. |
| Crystal size distribution | CQA/CMA | Critical | Affects filtration, drying, milling, blend uniformity, and dissolution. |
| Polymorphic form | CQA | Critical | Directly affects drug substance quality and product performance. |
| Impurity profile | CQA | Critical | Supports drug substance control and CMC quality sections. |

## Isolation, Filtration, And Washing

| CDE | Domain | Criticality | Why It Matters |
| --- | --- | --- | --- |
| Filtration pressure differential | CPP | Important | Indicates filtration performance and cake resistance. |
| Filtration time | CPP | Important | Supports process performance monitoring. |
| Wash solvent identity | Genealogy/CPP | Critical | Confirms intended wash material and residual solvent control. |
| Wash solvent volume | CPP | Critical | Affects impurity purge and residual solvent level. |
| Wet cake mass | Genealogy | Critical | Supports yield and material balance. |
| Mother liquor impurity level | CQA/IPC | Critical | Supports purge understanding and process control. |
| Wet cake residual solvent | CQA/IPC | Critical | Affects drying endpoint and residual solvent risk. |

## Drying

| CDE | Domain | Criticality | Why It Matters |
| --- | --- | --- | --- |
| Dryer inlet temperature | CPP | Critical | Affects drying rate and degradation risk. |
| Dryer outlet temperature | CPP | Important | Indicates process state and drying progression. |
| Vacuum level | CPP | Critical | Affects solvent removal and endpoint control. |
| Drying time | CPP | Important | Supports process performance and hold-time context. |
| Loss on drying endpoint | CQA/IPC | Critical | Confirms acceptable residual moisture/solvent state. |
| Residual solvent result | CQA | Critical | Supports drug substance specification and CMC evidence. |
| Dried API container ID | Genealogy | Critical | Connects dried API to downstream particle engineering. |

## Milling / Micronisation / Sieving

| CDE | Domain | Criticality | Why It Matters |
| --- | --- | --- | --- |
| Mill type | Equipment | Important | Supports equipment genealogy and process interpretation. |
| Mill speed | CPP | Critical | Affects particle size reduction and heat input. |
| Feed rate to mill | CPP | Critical | Affects mill loading and particle size distribution. |
| Screen size | CPP | Critical | Defines size cut and oversized particle control. |
| Classifier speed | CPP | Important | Relevant for air classifier or micronisation systems. |
| Milled API particle size distribution | CMA | Critical | Affects feeding, blending, content uniformity, and dissolution. |
| Bulk density | CMA | Critical | Affects feeder performance and blend density. |
| Tapped density | CMA | Important | Supports flow and compaction understanding. |
| Flowability index | CMA | Important | Supports feeder risk and blend flow interpretation. |
| API intermediate hold time | Genealogy/QMS | Critical | Supports material state control and batch record review. |

## CDC Direct Compression

| CDE | Domain | Criticality | Why It Matters |
| --- | --- | --- | --- |
| API lot ID | Genealogy | Critical | Links API input to finished tablet genealogy. |
| Excipient lot IDs | Genealogy | Critical | Links excipient inputs to finished tablet genealogy. |
| API feed rate | CPP | Critical | Directly affects potency and content uniformity risk. |
| Excipient feed rate | CPP | Critical | Affects blend composition and tablet weight. |
| Blender speed | CPP | Critical | Affects blend uniformity. |
| Residence time | CPP | Critical | Affects mixing completeness and diversion windows. |
| Inline NIR blend uniformity | CQA/PAT | Critical | Supports real-time process monitoring and deviation detection. |
| Lubricant feed rate | CPP | Critical | Affects hardness, friability, and dissolution. |
| Compression force | CPP | Critical | Controls tablet hardness and dissolution risk. |
| Turret speed | CPP | Important | Affects die fill and tablet weight variability. |
| Tablet weight | CQA/IPC | Critical | Supports in-process control and disposition. |
| Tablet hardness | CQA | Critical | Supports mechanical performance and dissolution interpretation. |
| Content uniformity | CQA | Critical | Core quality attribute for dose uniformity. |
| Dissolution | CQA | Critical | Supports drug product performance. |
| Friability | CQA | Critical | Supports tablet robustness. |

## Semi-Continuous Powder Coating

| CDE | Domain | Criticality | Why It Matters |
| --- | --- | --- | --- |
| Core tablet lot/segment ID | Genealogy | Critical | Links coating output back to compressed tablet segment. |
| Coating powder lot ID | Genealogy | Critical | Links coating material to coated product. |
| Coating powder feed rate | CPP | Critical | Affects coating weight gain and uniformity. |
| Tablet bed temperature | CPP | Critical | Affects coating adhesion and defect risk. |
| Inlet air temperature | CPP | Important | Supports thermal and powder adhesion control. |
| Relative humidity | CPP | Critical | Affects powder flow, adhesion, electrostatics, and appearance. |
| Coater pan/drum speed | CPP | Critical | Affects tablet movement and coating uniformity. |
| Coater residence time | CPP | Critical | Affects coating level and uniformity. |
| Electrostatic voltage | CPP | Important | Relevant where electrostatic powder coating is used. |
| Coating weight gain | CQA/IPC | Critical | Primary coated tablet coating amount indicator. |
| Coating uniformity | CQA | Critical | Supports appearance, performance, and release. |
| Coated tablet appearance | CQA | Important | Supports defect monitoring and release review. |
| Coated tablet reject rate | KPI/CQA | Important | Supports process performance and investigation. |
| Powder coated tablet container ID | Genealogy | Critical | Final output genealogy anchor. |

## Standards Mapping Summary

| Standards Context | CDE Use |
| --- | --- |
| ICH Q13 | Continuous manufacturing control strategy, process monitoring, state of control, material traceability, and regulatory expectations for drug substance and drug product continuous manufacturing. |
| ICH Q8/Q9/Q10/Q11/Q12 | Pharmaceutical development, quality risk management, pharmaceutical quality system, drug substance process understanding, lifecycle and change control. |
| ICH Q14 / Q2(R2) | Analytical procedure development and validation context for analytical-method CDEs. |
| CTD Module 3 / ICH M4Q | Regulatory CMC structure for drug substance and drug product quality information. |
| ISO/IEC 11179 | Data element definitions, naming, metadata registry, classification, identification, and mapping. |
| ISO 14644 | Cleanroom classification and environmental monitoring context. |
| ISO 22400 | Manufacturing operations KPI context. |
| ISA-95 / IEC 62264 | Enterprise-control system integration, equipment hierarchy, and source-system boundary context. |
