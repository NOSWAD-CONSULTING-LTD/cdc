# CDC Ontology Relationship Matrix

This matrix defines allowed subject-predicate-object patterns for the CDC ontology. Predicate names are written in lower camel case for ontology usage and map to Neo4j relationship types in upper snake case.

The machine-readable subset used by the demo agent and relationship-definition nodes is available in [relationship-map.json](relationship-map.json).

| Subject Class | Predicate | Object Class | Neo4j Relationship | Meaning |
| --- | --- | --- | --- | --- |
| Product | hasFormulation | Formulation | `HAS_FORMULATION` | Product has a versioned composition. |
| Product | hasRecipe | Recipe | `HAS_RECIPE` | Product is manufactured by a recipe. |
| Product | hasCMCPackage | CMCPackage | `HAS_CMC_PACKAGE` | Product is governed by a CMC package. |
| Formulation | usesMaterial | Material | `USES_MATERIAL` | Formulation includes a material. |
| MaterialLot | instanceOf | Material | `INSTANCE_OF` | Lot is an instance of material master. |
| MaterialLot | suppliedBy | Supplier | `SUPPLIED_BY` | Lot source supplier. |
| Recipe | definesStep | ProcessStep | `DEFINES_STEP` | Recipe contains a step. |
| ProcessStep | usesEquipment | Equipment | `USES_EQUIPMENT` | Step uses equipment. |
| ProcessStep | nextStep | ProcessStep | `NEXT_STEP` | Ordered process step sequence. |
| ProcessSegment | containsOperation | UnitOperation | `CONTAINS_OPERATION` | Segment contains a unit operation. |
| UnitOperation | nextOperation | UnitOperation | `NEXT_OPERATION` | Ordered end-to-end operation sequence. |
| UnitOperation | produces | IntermediateProduct | `PRODUCES` | Operation produces a material state. |
| UnitOperation | hasTransformation | MaterialTransformation | `HAS_TRANSFORMATION` | Operation changes material state. |
| UnitOperation | hasControlPoint | ControlPoint | `HAS_CONTROL_POINT` | Operation has a control point. |
| UnitOperation | hasSamplingPoint | SamplingPoint | `HAS_SAMPLING_POINT` | Operation has a sampling point. |
| UnitOperation | alignsToProcessStep | ProcessStep | `ALIGNS_TO_PROCESS_STEP` | Conceptual operation maps to recipe step. |
| ManufacturingSite | hasLine | ManufacturingLine | `HAS_LINE` | Site contains a line. |
| ManufacturingLine | hasRoom | Room | `HAS_ROOM` | Line includes room. |
| ManufacturingLine | includesEquipment | Equipment | `INCLUDES_EQUIPMENT` | Line includes equipment. |
| Equipment | locatedIn | Room | `LOCATED_IN` | Equipment location. |
| Equipment | hasSensor | Sensor | `HAS_SENSOR` | Equipment has sensor or instrument. |
| Sensor | measures | CPP | `MEASURES` | Sensor measures a process parameter. |
| Sensor | measures | CQA | `MEASURES` | Sensor measures or predicts quality attribute. |
| SensorReading | recordedBy | Sensor | `RECORDED_BY` | Reading source sensor. |
| SensorReading | duringRun | ManufacturingRun | `DURING_RUN` | Reading occurred during run. |
| SensorReading | observes | CPP/CQA | `OBSERVES` | Reading observes measured concept. |
| CPP | controls | ProcessStep | `CONTROLS` | CPP controls or influences a step. |
| CPP | impacts | CQA | `IMPACTS` | CPP can affect CQA. |
| CQA | hasSpecification | Specification | `HAS_SPECIFICATION` | CQA has acceptance criterion. |
| CriticalMaterialAttribute | characterizes | Material | `CHARACTERIZES` | CMA describes material attribute. |
| ManufacturingRun | executes | Recipe | `EXECUTES` | Run executes recipe. |
| ManufacturingRun | atSite | ManufacturingSite | `AT_SITE` | Run occurs at site. |
| ManufacturingRun | usesLine | ManufacturingLine | `USES_LINE` | Run uses line. |
| ManufacturingRun | consumes | MaterialLot | `CONSUMES` | Run consumes material lot. |
| ManufacturingRun | hasBatchRecord | BatchRecord | `HAS_BATCH_RECORD` | Run has batch record. |
| ManufacturingRun | hasDeviation | Deviation | `HAS_DEVIATION` | Run has deviation. |
| Alarm | triggeredBy | SensorReading | `TRIGGERED_BY` | Alarm triggered by reading. |
| Deviation | investigates | Alarm | `INVESTIGATES` | Deviation investigates alarm. |
| Deviation | considersReading | SensorReading | `CONSIDERS_READING` | Deviation considers supporting reading. |
| QAReleaseDecision | reviews | BatchRecord | `REVIEWS` | QA decision reviews batch record. |
| QAReleaseDecision | releases | ManufacturingRun | `RELEASES` | QA decision releases run. |
| QAReleaseDecision | rejects | ManufacturingRun | `REJECTS` | QA decision rejects or quarantines run. |
| RegulatoryFiling | covers | Product | `COVERS` | Filing covers product. |
| RegulatoryFiling | submits | CMCPackage | `SUBMITS` | Filing submits CMC package. |
| ValidationEvidence | supports | RegulatoryFiling | `SUPPORTS` | Evidence supports filing. |
| CMCPackage | includes | ControlStrategy | `INCLUDES` | CMC package includes control strategy. |
| CMCPackage | includes | ProcessValidation | `INCLUDES` | CMC package includes validation. |
| CMCPackage | includes | AnalyticalMethod | `INCLUDES` | CMC package includes method. |
| CMCPackage | includes | StabilityStudy | `INCLUDES` | CMC package includes stability. |
| CMCPackage | referencesSOP | SOP | `REFERENCES_SOP` | CMC package references SOP. |
| CMCPackage | governsCDE | CriticalDataElement | `GOVERNS_CDE` | CMC package governs CDE. |
| CMCPackage | referencesStandard | DataStandard | `REFERENCES_STANDARD` | CMC package anchors standards used as reference context. |
| CMCPackage | referencesCMCSection | RegulatorySection | `REFERENCES_CMC_SECTION` | CMC package anchors CMC sections used as reference context. |
| CMCPackage | hasDataOwner | DataOwner | `HAS_DATA_OWNER` | CMC package anchors data owners used in the CDE registry. |
| CMCPackage | referencesUnit | UnitOfMeasure | `REFERENCES_UNIT` | CMC package anchors units used as reference context. |
| ControlStrategy | controls | CPP | `CONTROLS` | Strategy controls CPP. |
| ControlStrategy | protects | CQA | `PROTECTS` | Strategy protects CQA. |
| ControlStrategy | controlsMaterialAttribute | CriticalMaterialAttribute | `CONTROLS_MATERIAL_ATTRIBUTE` | Strategy controls CMA. |
| ControlStrategy | usesCDE | CriticalDataElement | `USES_CDE` | Strategy uses CDE. |
| AnalyticalMethod | measures | CQA | `MEASURES` | Method measures CQA. |
| StabilityStudy | monitors | CQA | `MONITORS` | Stability study monitors CQA. |
| SOP | governsRecipe | Recipe | `GOVERNS_RECIPE` | SOP governs recipe/process. |
| TrainingRecord | coversSOP | SOP | `COVERS_SOP` | Training covers SOP. |
| EquipmentQualification | qualifies | Equipment | `QUALIFIES` | Qualification qualifies equipment. |
| ComputerSystemValidation | validatesDataSource | Sensor | `VALIDATES_DATA_SOURCE` | CSV validates data source/sensor. |
| AuditTrailEvent | documents | SensorReading/Alarm/Deviation/QAReleaseDecision | `DOCUMENTS` | Audit event documents regulated event. |
| CriticalDataElement | observedAt | UnitOperation | `OBSERVED_AT` | CDE is observed or used at operation. |
| CriticalDataElement | describes | CPP/CQA/CMA/MaterialLot/Equipment/Sensor/IntermediateProduct | `DESCRIBES` | CDE describes a domain concept. |
| CriticalDataElement | sourcedFrom | DataSourceSystem | `SOURCED_FROM` | CDE originates from source system. |
| CriticalDataElement | hasDataQualityRule | DataQualityRule | `HAS_DATA_QUALITY_RULE` | CDE requires DQ rule. |
| CriticalDataElement | hasOwner | DataOwner | `HAS_OWNER` | CDE has accountable owner. |
| CriticalDataElement | hasSteward | DataSteward | `HAS_STEWARD` | CDE has steward. |
| CriticalDataElement | mapsToStandard | DataStandard | `MAPS_TO_STANDARD` | CDE maps to standard context. |
| CriticalDataElement | supportsCMCSection | RegulatorySection | `SUPPORTS_CMC_SECTION` | CDE supports CTD/CMC section. |
| CriticalDataElement | hasValueDomain | ValueDomain | `HAS_VALUE_DOMAIN` | CDE has data type, unit, or allowed-value context. |
| CDEValue | valueOf | CriticalDataElement | `VALUE_OF` | Observed or textual value instantiates a CDE definition. |
| CDEValue | conformsToValueDomain | ValueDomain | `CONFORMS_TO_VALUE_DOMAIN` | Value is interpreted against the CDE value domain. |
| CDEValue | observedDuring | ManufacturingRun | `OBSERVED_DURING` | Value belongs to a manufacturing run context. |
| CDEValue | derivedFromReading | SensorReading | `DERIVED_FROM_READING` | Value is derived from or supported by a process or PAT reading. |
| CDEVersion | versionOf | CriticalDataElement | `VERSION_OF` | Versioned definition belongs to a CDE. |
| CDEDefinitionApproval | approves | CDEVersion | `APPROVES` | Approval records governance of a CDE definition version. |
| StandardMapping | mapsCDE | CriticalDataElement | `MAPS_CDE` | Mapping references CDE. |
| StandardMapping | toStandard | DataStandard | `TO_STANDARD` | Mapping references standard. |
| StandardMapping | toRegulatorySection | RegulatorySection | `TO_REGULATORY_SECTION` | Mapping references regulatory section. |
| StandardMapping | supportedByProvenance | ProvenanceStatement | `SUPPORTED_BY_PROVENANCE` | Mapping is supported by standards provenance context. |
| EvidenceDocument | evidencesCDE | CriticalDataElement | `EVIDENCES_CDE` | Evidence document supports a CDE definition. |
| EvidenceDocument | evidencesCDEValue | CDEValue | `EVIDENCES_CDE_VALUE` | Evidence document supports an observed CDE value. |
| EvidenceDocument | evidencesReading | SensorReading | `EVIDENCES_READING` | Evidence document supports a sensor reading. |
| EvidenceDocument | supportsDeviation | Deviation | `SUPPORTS_DEVIATION` | Evidence document supports a deviation investigation. |
| EvidenceDocument | supportsMapping | StandardMapping | `SUPPORTS_MAPPING` | Evidence document supports a CDE-to-standard mapping. |
| EvidenceDocument | supportsCMCSection | RegulatorySection | `SUPPORTS_CMC_SECTION` | Evidence document supports a CMC section. |
| EvidenceDocument | documentsRun | ManufacturingRun | `DOCUMENTS_RUN` | Evidence document records run-level evidence. |
| EvidenceDocument | documentsBatchRecord | BatchRecord | `DOCUMENTS_BATCH_RECORD` | Evidence document records batch-record evidence. |
| EvidenceDocument | documentsQADecision | QAReleaseDecision | `DOCUMENTS_QA_DECISION` | Evidence document records QA decision evidence. |
| CriticalDataElement | hasCDEDomain | CDEDomain | `HAS_CDE_DOMAIN` | CDE is classified by controlled domain vocabulary. |
| CriticalDataElement | hasCriticalityLevel | CriticalityLevel | `HAS_CRITICALITY_LEVEL` | CDE is classified by controlled criticality vocabulary. |
| QAReleaseDecision | hasDecisionStatus | DecisionStatus | `HAS_DECISION_STATUS` | QA decision is classified by controlled status vocabulary. |
| ManufacturingRun | hasRunStatus | RunStatus | `HAS_RUN_STATUS` | Run is classified by controlled status vocabulary. |
| Deviation | hasDeviationSeverity | DeviationSeverity | `HAS_DEVIATION_SEVERITY` | Deviation is classified by controlled severity vocabulary. |
| CMCPackage | referencesRelationshipDefinition | RelationshipDefinition | `REFERENCES_RELATIONSHIP_DEFINITION` | CMC package anchors relationship mapping reference data. |
