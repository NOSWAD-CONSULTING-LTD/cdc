// CDC manufacturing knowledge graph constraints and indexes.
// Neo4j 5 syntax. Constraints are idempotent and safe to rerun.

// Master data and ontology-like entities.
CREATE CONSTRAINT product_id_unique IF NOT EXISTS
FOR (n:Product) REQUIRE n.productId IS UNIQUE;

CREATE CONSTRAINT formulation_id_unique IF NOT EXISTS
FOR (n:Formulation) REQUIRE n.formulationId IS UNIQUE;

CREATE CONSTRAINT recipe_id_unique IF NOT EXISTS
FOR (n:Recipe) REQUIRE n.recipeId IS UNIQUE;

CREATE CONSTRAINT material_id_unique IF NOT EXISTS
FOR (n:Material) REQUIRE n.materialId IS UNIQUE;

CREATE CONSTRAINT supplier_id_unique IF NOT EXISTS
FOR (n:Supplier) REQUIRE n.supplierId IS UNIQUE;

CREATE CONSTRAINT site_id_unique IF NOT EXISTS
FOR (n:ManufacturingSite) REQUIRE n.siteId IS UNIQUE;

CREATE CONSTRAINT line_id_unique IF NOT EXISTS
FOR (n:ManufacturingLine) REQUIRE n.lineId IS UNIQUE;

CREATE CONSTRAINT room_id_unique IF NOT EXISTS
FOR (n:Room) REQUIRE n.roomId IS UNIQUE;

CREATE CONSTRAINT equipment_id_unique IF NOT EXISTS
FOR (n:Equipment) REQUIRE n.equipmentId IS UNIQUE;

CREATE CONSTRAINT process_step_id_unique IF NOT EXISTS
FOR (n:ProcessStep) REQUIRE n.stepId IS UNIQUE;

CREATE CONSTRAINT sensor_id_unique IF NOT EXISTS
FOR (n:Sensor) REQUIRE n.sensorId IS UNIQUE;

CREATE CONSTRAINT cpp_id_unique IF NOT EXISTS
FOR (n:CPP) REQUIRE n.cppId IS UNIQUE;

CREATE CONSTRAINT cqa_id_unique IF NOT EXISTS
FOR (n:CQA) REQUIRE n.cqaId IS UNIQUE;

CREATE CONSTRAINT specification_id_unique IF NOT EXISTS
FOR (n:Specification) REQUIRE n.specificationId IS UNIQUE;

CREATE CONSTRAINT filing_id_unique IF NOT EXISTS
FOR (n:RegulatoryFiling) REQUIRE n.filingId IS UNIQUE;

CREATE CONSTRAINT evidence_id_unique IF NOT EXISTS
FOR (n:ValidationEvidence) REQUIRE n.evidenceId IS UNIQUE;

CREATE CONSTRAINT cmc_package_id_unique IF NOT EXISTS
FOR (n:CMCPackage) REQUIRE n.cmcPackageId IS UNIQUE;

CREATE CONSTRAINT control_strategy_id_unique IF NOT EXISTS
FOR (n:ControlStrategy) REQUIRE n.controlStrategyId IS UNIQUE;

CREATE CONSTRAINT process_validation_id_unique IF NOT EXISTS
FOR (n:ProcessValidation) REQUIRE n.processValidationId IS UNIQUE;

CREATE CONSTRAINT analytical_method_id_unique IF NOT EXISTS
FOR (n:AnalyticalMethod) REQUIRE n.methodId IS UNIQUE;

CREATE CONSTRAINT stability_study_id_unique IF NOT EXISTS
FOR (n:StabilityStudy) REQUIRE n.stabilityStudyId IS UNIQUE;

CREATE CONSTRAINT change_control_id_unique IF NOT EXISTS
FOR (n:ChangeControl) REQUIRE n.changeControlId IS UNIQUE;

CREATE CONSTRAINT risk_assessment_id_unique IF NOT EXISTS
FOR (n:RiskAssessment) REQUIRE n.riskAssessmentId IS UNIQUE;

CREATE CONSTRAINT critical_material_attribute_id_unique IF NOT EXISTS
FOR (n:CriticalMaterialAttribute) REQUIRE n.cmaId IS UNIQUE;

CREATE CONSTRAINT sop_id_unique IF NOT EXISTS
FOR (n:SOP) REQUIRE n.sopId IS UNIQUE;

CREATE CONSTRAINT training_record_id_unique IF NOT EXISTS
FOR (n:TrainingRecord) REQUIRE n.trainingRecordId IS UNIQUE;

CREATE CONSTRAINT equipment_qualification_id_unique IF NOT EXISTS
FOR (n:EquipmentQualification) REQUIRE n.equipmentQualificationId IS UNIQUE;

CREATE CONSTRAINT computer_system_validation_id_unique IF NOT EXISTS
FOR (n:ComputerSystemValidation) REQUIRE n.csvId IS UNIQUE;

CREATE CONSTRAINT audit_trail_event_id_unique IF NOT EXISTS
FOR (n:AuditTrailEvent) REQUIRE n.auditTrailEventId IS UNIQUE;

CREATE CONSTRAINT unit_operation_id_unique IF NOT EXISTS
FOR (n:UnitOperation) REQUIRE n.unitOperationId IS UNIQUE;

CREATE CONSTRAINT process_segment_id_unique IF NOT EXISTS
FOR (n:ProcessSegment) REQUIRE n.processSegmentId IS UNIQUE;

CREATE CONSTRAINT critical_data_element_id_unique IF NOT EXISTS
FOR (n:CriticalDataElement) REQUIRE n.cdeId IS UNIQUE;

CREATE CONSTRAINT data_standard_id_unique IF NOT EXISTS
FOR (n:DataStandard) REQUIRE n.standardId IS UNIQUE;

CREATE CONSTRAINT standard_mapping_id_unique IF NOT EXISTS
FOR (n:StandardMapping) REQUIRE n.mappingId IS UNIQUE;

CREATE CONSTRAINT data_source_system_id_unique IF NOT EXISTS
FOR (n:DataSourceSystem) REQUIRE n.sourceSystemId IS UNIQUE;

CREATE CONSTRAINT data_owner_id_unique IF NOT EXISTS
FOR (n:DataOwner) REQUIRE n.ownerId IS UNIQUE;

CREATE CONSTRAINT data_steward_id_unique IF NOT EXISTS
FOR (n:DataSteward) REQUIRE n.stewardId IS UNIQUE;

CREATE CONSTRAINT data_quality_rule_id_unique IF NOT EXISTS
FOR (n:DataQualityRule) REQUIRE n.ruleId IS UNIQUE;

CREATE CONSTRAINT control_point_id_unique IF NOT EXISTS
FOR (n:ControlPoint) REQUIRE n.controlPointId IS UNIQUE;

CREATE CONSTRAINT material_transformation_id_unique IF NOT EXISTS
FOR (n:MaterialTransformation) REQUIRE n.transformationId IS UNIQUE;

CREATE CONSTRAINT intermediate_product_id_unique IF NOT EXISTS
FOR (n:IntermediateProduct) REQUIRE n.intermediateProductId IS UNIQUE;

CREATE CONSTRAINT process_state_id_unique IF NOT EXISTS
FOR (n:ProcessState) REQUIRE n.processStateId IS UNIQUE;

CREATE CONSTRAINT sampling_point_id_unique IF NOT EXISTS
FOR (n:SamplingPoint) REQUIRE n.samplingPointId IS UNIQUE;

CREATE CONSTRAINT analytical_result_id_unique IF NOT EXISTS
FOR (n:AnalyticalResult) REQUIRE n.analyticalResultId IS UNIQUE;

CREATE CONSTRAINT regulatory_section_id_unique IF NOT EXISTS
FOR (n:RegulatorySection) REQUIRE n.sectionId IS UNIQUE;

CREATE CONSTRAINT value_domain_id_unique IF NOT EXISTS
FOR (n:ValueDomain) REQUIRE n.valueDomainId IS UNIQUE;

CREATE CONSTRAINT unit_of_measure_id_unique IF NOT EXISTS
FOR (n:UnitOfMeasure) REQUIRE n.unitId IS UNIQUE;

CREATE CONSTRAINT allowed_value_id_unique IF NOT EXISTS
FOR (n:AllowedValue) REQUIRE n.allowedValueId IS UNIQUE;

CREATE CONSTRAINT cde_version_id_unique IF NOT EXISTS
FOR (n:CDEVersion) REQUIRE n.cdeVersionId IS UNIQUE;

CREATE CONSTRAINT cde_definition_approval_id_unique IF NOT EXISTS
FOR (n:CDEDefinitionApproval) REQUIRE n.approvalId IS UNIQUE;

CREATE CONSTRAINT cde_value_id_unique IF NOT EXISTS
FOR (n:CDEValue) REQUIRE n.cdeValueId IS UNIQUE;

CREATE CONSTRAINT provenance_statement_id_unique IF NOT EXISTS
FOR (n:ProvenanceStatement) REQUIRE n.provenanceId IS UNIQUE;

CREATE CONSTRAINT evidence_document_id_unique IF NOT EXISTS
FOR (n:EvidenceDocument) REQUIRE n.documentId IS UNIQUE;

CREATE CONSTRAINT cde_domain_id_unique IF NOT EXISTS
FOR (n:CDEDomain) REQUIRE n.domainId IS UNIQUE;

CREATE CONSTRAINT criticality_level_id_unique IF NOT EXISTS
FOR (n:CriticalityLevel) REQUIRE n.criticalityId IS UNIQUE;

CREATE CONSTRAINT decision_status_id_unique IF NOT EXISTS
FOR (n:DecisionStatus) REQUIRE n.decisionStatusId IS UNIQUE;

CREATE CONSTRAINT deviation_severity_id_unique IF NOT EXISTS
FOR (n:DeviationSeverity) REQUIRE n.severityId IS UNIQUE;

CREATE CONSTRAINT run_status_id_unique IF NOT EXISTS
FOR (n:RunStatus) REQUIRE n.runStatusId IS UNIQUE;

CREATE CONSTRAINT relationship_definition_id_unique IF NOT EXISTS
FOR (n:RelationshipDefinition) REQUIRE n.relationshipDefinitionId IS UNIQUE;

// Transactional manufacturing entities.
CREATE CONSTRAINT material_lot_id_unique IF NOT EXISTS
FOR (n:MaterialLot) REQUIRE n.lotId IS UNIQUE;

CREATE CONSTRAINT manufacturing_run_id_unique IF NOT EXISTS
FOR (n:ManufacturingRun) REQUIRE n.runId IS UNIQUE;

CREATE CONSTRAINT sensor_reading_id_unique IF NOT EXISTS
FOR (n:SensorReading) REQUIRE n.readingId IS UNIQUE;

CREATE CONSTRAINT deviation_id_unique IF NOT EXISTS
FOR (n:Deviation) REQUIRE n.deviationId IS UNIQUE;

CREATE CONSTRAINT alarm_id_unique IF NOT EXISTS
FOR (n:Alarm) REQUIRE n.alarmId IS UNIQUE;

CREATE CONSTRAINT cleaning_record_id_unique IF NOT EXISTS
FOR (n:CleaningRecord) REQUIRE n.cleaningRecordId IS UNIQUE;

CREATE CONSTRAINT calibration_record_id_unique IF NOT EXISTS
FOR (n:CalibrationRecord) REQUIRE n.calibrationRecordId IS UNIQUE;

CREATE CONSTRAINT operator_id_unique IF NOT EXISTS
FOR (n:Operator) REQUIRE n.operatorId IS UNIQUE;

CREATE CONSTRAINT batch_record_id_unique IF NOT EXISTS
FOR (n:BatchRecord) REQUIRE n.batchRecordId IS UNIQUE;

CREATE CONSTRAINT qa_decision_id_unique IF NOT EXISTS
FOR (n:QAReleaseDecision) REQUIRE n.decisionId IS UNIQUE;

// Helpful lookup indexes for common investigations.
CREATE INDEX manufacturing_run_status_idx IF NOT EXISTS
FOR (n:ManufacturingRun) ON (n.status);

CREATE INDEX manufacturing_run_start_time_idx IF NOT EXISTS
FOR (n:ManufacturingRun) ON (n.startTime);

CREATE INDEX material_lot_number_idx IF NOT EXISTS
FOR (n:MaterialLot) ON (n.lotNumber);

CREATE INDEX sensor_reading_timestamp_idx IF NOT EXISTS
FOR (n:SensorReading) ON (n.timestamp);

CREATE INDEX sensor_reading_status_idx IF NOT EXISTS
FOR (n:SensorReading) ON (n.status);

CREATE INDEX deviation_status_idx IF NOT EXISTS
FOR (n:Deviation) ON (n.status);

CREATE INDEX alarm_severity_idx IF NOT EXISTS
FOR (n:Alarm) ON (n.severity);

CREATE INDEX change_control_status_idx IF NOT EXISTS
FOR (n:ChangeControl) ON (n.status);

CREATE INDEX sop_status_idx IF NOT EXISTS
FOR (n:SOP) ON (n.status);

CREATE INDEX audit_trail_timestamp_idx IF NOT EXISTS
FOR (n:AuditTrailEvent) ON (n.timestamp);

CREATE INDEX cde_criticality_idx IF NOT EXISTS
FOR (n:CriticalDataElement) ON (n.criticality);

CREATE INDEX cde_domain_idx IF NOT EXISTS
FOR (n:CriticalDataElement) ON (n.domain);

CREATE INDEX unit_operation_order_idx IF NOT EXISTS
FOR (n:UnitOperation) ON (n.operationOrder);

CREATE INDEX cde_value_timestamp_idx IF NOT EXISTS
FOR (n:CDEValue) ON (n.timestamp);

CREATE INDEX cde_value_status_idx IF NOT EXISTS
FOR (n:CDEValue) ON (n.status);

CREATE INDEX provenance_source_idx IF NOT EXISTS
FOR (n:ProvenanceStatement) ON (n.sourceUrl);

CREATE INDEX evidence_document_type_idx IF NOT EXISTS
FOR (n:EvidenceDocument) ON (n.documentType);

CREATE INDEX relationship_definition_type_idx IF NOT EXISTS
FOR (n:RelationshipDefinition) ON (n.neo4jType);
