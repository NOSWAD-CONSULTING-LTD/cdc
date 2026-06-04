// CMC, ISO/GMP, and QMS extension queries.

// 1. Show the CMC package connected to product, filing, and included evidence.
MATCH path = (:Product {productId: 'PROD-NCL-CDC-TAB-10MG'})-[:HAS_CMC_PACKAGE]->(:CMCPackage)<-[:SUBMITS]-(:RegulatoryFiling)
RETURN path;

MATCH path = (:CMCPackage {cmcPackageId: 'CMC-NCL-CDC-10MG-001'})-[:INCLUDES|REFERENCES_SOP]->()
RETURN path;

// 2. Show the control strategy: CMAs, CPPs, CQAs, and recipe governed.
MATCH (strategy:ControlStrategy {controlStrategyId: 'CS-NCL-CDC-10MG-001'})
OPTIONAL MATCH cmaPath = (strategy)-[:CONTROLS_MATERIAL_ATTRIBUTE]->(:CriticalMaterialAttribute)-[:CHARACTERIZES]->(:Material)
OPTIONAL MATCH cppPath = (strategy)-[:CONTROLS]->(:CPP)-[:CONTROLS]->(:ProcessStep)
OPTIONAL MATCH cqaPath = (strategy)-[:PROTECTS]->(:CQA)-[:HAS_SPECIFICATION]->(:Specification)
OPTIONAL MATCH recipePath = (strategy)-[:GOVERNS_RECIPE]->(:Recipe)
RETURN cmaPath, cppPath, cqaPath, recipePath;

// 3. Find CMC controls and methods protecting a selected CQA.
MATCH (cqa:CQA {cqaId: 'CQA-CONTENT-UNIFORMITY'})
OPTIONAL MATCH (strategy:ControlStrategy)-[:PROTECTS]->(cqa)
OPTIONAL MATCH (cpp:CPP)-[:IMPACTS]->(cqa)
OPTIONAL MATCH (method:AnalyticalMethod)-[:MEASURES]->(cqa)
OPTIONAL MATCH (stability:StabilityStudy)-[:MONITORS]->(cqa)
RETURN cqa.name AS cqa,
       collect(DISTINCT strategy.name) AS controlStrategies,
       collect(DISTINCT cpp.name) AS impactingCpps,
       collect(DISTINCT method.name) AS analyticalMethods,
       collect(DISTINCT stability.name) AS stabilityStudies;

// 4. Trace a released run through batch record, QMS controls, audit trail, and QA decision.
MATCH (run:ManufacturingRun {runId: 'RUN-CDC-2026-06-01-001'})-[:HAS_BATCH_RECORD]->(br:BatchRecord)
OPTIONAL MATCH (br)-[:REVIEWED_UNDER]->(reviewSop:SOP)
OPTIONAL MATCH (br)-[:HAS_AUDIT_TRAIL_EVENT]->(audit:AuditTrailEvent)
OPTIONAL MATCH (decision:QAReleaseDecision)-[:REVIEWS]->(br)
OPTIONAL MATCH (decision)-[:RELEASES]->(run)
RETURN run.batchNumber AS batchNumber,
       br.status AS batchRecordStatus,
       collect(DISTINCT reviewSop.title) AS reviewSops,
       collect(DISTINCT audit.action) AS auditTrailActions,
       decision.decision AS qaDecision,
       decision.rationale AS rationale;

// 5. Show deviation governance: alarm, readings, SOP, audit trail, and QA approval.
MATCH (run:ManufacturingRun)-[:HAS_DEVIATION]->(dev:Deviation {deviationId: 'DEV-CDC-20260601-001'})
OPTIONAL MATCH (dev)-[:INVESTIGATES]->(alarm:Alarm)-[:TRIGGERED_BY]->(reading:SensorReading)
OPTIONAL MATCH (dev)-[:HANDLED_UNDER]->(sop:SOP)
OPTIONAL MATCH (dev)<-[:DOCUMENTS]-(audit:AuditTrailEvent)
OPTIONAL MATCH (dev)-[:APPROVED_BY]->(qa:Operator)
RETURN run.batchNumber AS batchNumber,
       dev.title AS deviation,
       alarm.alarmCode AS alarmCode,
       reading.readingId AS triggeringReading,
       sop.title AS governingSop,
       collect(DISTINCT audit.action) AS auditTrailActions,
       qa.name AS approvedBy,
       dev.impactAssessment AS impactAssessment;

// 6. Show equipment qualification and computerized system validation for sensors used in the run.
MATCH (run:ManufacturingRun {runId: 'RUN-CDC-2026-06-01-001'})-[:EXECUTES]->(:Recipe)-[:DEFINES_STEP]->(:ProcessStep)-[:USES_EQUIPMENT]->(equipment:Equipment)
OPTIONAL MATCH (qualification:EquipmentQualification)-[:QUALIFIES]->(equipment)
OPTIONAL MATCH (equipment)-[:HAS_SENSOR]->(sensor:Sensor)
OPTIONAL MATCH (csv:ComputerSystemValidation)-[:VALIDATES_DATA_SOURCE]->(sensor)
RETURN equipment.name AS equipment,
       collect(DISTINCT qualification.name) AS equipmentQualification,
       collect(DISTINCT sensor.name) AS sensors,
       collect(DISTINCT csv.name) AS computerSystemValidation
ORDER BY equipment;

// 7. Show operator training evidence for people who signed or approved the run.
MATCH (run:ManufacturingRun {runId: 'RUN-CDC-2026-06-01-001'})-[:HAS_BATCH_RECORD]->(br:BatchRecord)
OPTIONAL MATCH (br)-[:SIGNED_BY]->(op:Operator)
OPTIONAL MATCH (:Deviation)<-[:HAS_DEVIATION]-(run)
OPTIONAL MATCH (:Deviation)-[:APPROVED_BY]->(qa:Operator)
WITH collect(DISTINCT op) + collect(DISTINCT qa) AS people
UNWIND people AS person
MATCH (person)-[:HAS_TRAINING]->(training:TrainingRecord)-[:COVERS_SOP]->(sop:SOP)
RETURN person.name AS person,
       person.role AS role,
       training.status AS trainingStatus,
       training.completedAt AS completedAt,
       sop.title AS sop
ORDER BY person, sop;

// 8. Graph-friendly CMC/QMS visualisation.
MATCH (cmc:CMCPackage {cmcPackageId: 'CMC-NCL-CDC-10MG-001'})
OPTIONAL MATCH packagePath = (cmc)-[:INCLUDES|REFERENCES_SOP]->()
OPTIONAL MATCH productPath = (:Product)-[:HAS_CMC_PACKAGE]->(cmc)<-[:SUBMITS]-(:RegulatoryFiling)
OPTIONAL MATCH controlPath = (cmc)-[:INCLUDES]->(:ControlStrategy)-[:CONTROLS|PROTECTS|CONTROLS_MATERIAL_ATTRIBUTE]->()
OPTIONAL MATCH validationPath = (cmc)-[:INCLUDES]->(:ProcessValidation)-[:VALIDATES|USES_RUN_EVIDENCE|SUPPORTED_BY]->()
RETURN packagePath, productPath, controlPath, validationPath;
