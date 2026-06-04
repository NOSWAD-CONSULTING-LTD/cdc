// CMC, ISO/GMP, and quality-system governance extension.
// This layer connects product/process master data and manufacturing execution
// evidence to regulatory and quality management concepts.

// ---------------------------------------------------------------------------
// CMC package and control strategy
// ---------------------------------------------------------------------------
MATCH (product:Product {productId: 'PROD-NCL-CDC-TAB-10MG'})
MATCH (filing:RegulatoryFiling {filingId: 'REG-FILING-NCL-CDC-DEMO-001'})
MERGE (cmc:CMCPackage {cmcPackageId: 'CMC-NCL-CDC-10MG-001'})
SET cmc.name = 'NCL-CDC-Tablet-10mg CMC knowledge package',
    cmc.lifecycleStage = 'Clinical manufacturing demonstration',
    cmc.scope = 'Chemistry, Manufacturing, and Controls for continuous direct compression demo',
    cmc.status = 'Reference architecture',
    cmc.version = '1.0'
MERGE (product)-[:HAS_CMC_PACKAGE]->(cmc)
MERGE (filing)-[:SUBMITS]->(cmc);

MATCH (cmc:CMCPackage {cmcPackageId: 'CMC-NCL-CDC-10MG-001'})
MERGE (strategy:ControlStrategy {controlStrategyId: 'CS-NCL-CDC-10MG-001'})
SET strategy.name = 'CDC integrated control strategy',
    strategy.strategyType = 'ICH Q8/Q9/Q10-inspired control strategy',
    strategy.summary = 'Links material attributes, CPPs, PAT monitoring, CQA specifications, alarms, deviations, and QA disposition.',
    strategy.status = 'Approved for demonstration'
MERGE (cmc)-[:INCLUDES]->(strategy);

MATCH (strategy:ControlStrategy {controlStrategyId: 'CS-NCL-CDC-10MG-001'})
MATCH (recipe:Recipe {recipeId: 'REC-NCL-CDC-DC-001'})
MERGE (strategy)-[:GOVERNS_RECIPE]->(recipe);

MATCH (strategy:ControlStrategy {controlStrategyId: 'CS-NCL-CDC-10MG-001'})
MATCH (cpp:CPP)
MERGE (strategy)-[:CONTROLS]->(cpp);

MATCH (strategy:ControlStrategy {controlStrategyId: 'CS-NCL-CDC-10MG-001'})
MATCH (cqa:CQA)
MERGE (strategy)-[:PROTECTS]->(cqa);

// ---------------------------------------------------------------------------
// Critical material attributes, material controls, and risk assessment
// ---------------------------------------------------------------------------
UNWIND [
  {id: 'CMA-API-PSD', name: 'API particle size distribution', materialId: 'MAT-NCL-API-10', unit: 'um', lower: 10.0, upper: 90.0, rationale: 'Particle size can influence feeding, blending, content uniformity, and dissolution.'},
  {id: 'CMA-API-POTENCY', name: 'API potency', materialId: 'MAT-NCL-API-10', unit: '% label claim', lower: 98.0, upper: 102.0, rationale: 'Potency correction is required for accurate formulation input.'},
  {id: 'CMA-MCC-BD', name: 'MCC bulk density', materialId: 'MAT-MCC-DC-102', unit: 'g/mL', lower: 0.25, upper: 0.40, rationale: 'Bulk density affects feeder refill behavior and blend density.'},
  {id: 'CMA-LACTOSE-MOISTURE', name: 'Lactose moisture', materialId: 'MAT-LACTOSE-SD', unit: '% w/w', lower: 0.0, upper: 5.0, rationale: 'Moisture can influence flow, compaction, and stability.'},
  {id: 'CMA-MGST-SSA', name: 'Magnesium stearate surface area', materialId: 'MAT-MG-STEARATE', unit: 'm2/g', lower: 4.0, upper: 10.0, rationale: 'Lubricant surface area can influence dissolution and tablet hardness.'}
] AS row
MATCH (material:Material {materialId: row.materialId})
MERGE (cma:CriticalMaterialAttribute {cmaId: row.id})
SET cma.name = row.name,
    cma.unit = row.unit,
    cma.lowerLimit = row.lower,
    cma.upperLimit = row.upper,
    cma.rationale = row.rationale,
    cma.status = 'Controlled'
MERGE (cma)-[:CHARACTERIZES]->(material);

MATCH (strategy:ControlStrategy {controlStrategyId: 'CS-NCL-CDC-10MG-001'})
MATCH (cma:CriticalMaterialAttribute)
MERGE (strategy)-[:CONTROLS_MATERIAL_ATTRIBUTE]->(cma);

MERGE (risk:RiskAssessment {riskAssessmentId: 'RA-NCL-CDC-FMEA-001'})
SET risk.name = 'CDC process and product quality FMEA',
    risk.method = 'FMEA',
    risk.status = 'Approved for demonstration',
    risk.summary = 'Assesses relationships among CMAs, CPPs, CQAs, control actions, and quality event handling.',
    risk.reviewDate = date('2026-05-05');

MATCH (cmc:CMCPackage {cmcPackageId: 'CMC-NCL-CDC-10MG-001'})
MATCH (risk:RiskAssessment {riskAssessmentId: 'RA-NCL-CDC-FMEA-001'})
MERGE (cmc)-[:INCLUDES]->(risk);

MATCH (risk:RiskAssessment {riskAssessmentId: 'RA-NCL-CDC-FMEA-001'})
MATCH (cpp:CPP)
MERGE (risk)-[:ASSESSES]->(cpp);

MATCH (risk:RiskAssessment {riskAssessmentId: 'RA-NCL-CDC-FMEA-001'})
MATCH (cqa:CQA)
MERGE (risk)-[:ASSESSES]->(cqa);

MATCH (risk:RiskAssessment {riskAssessmentId: 'RA-NCL-CDC-FMEA-001'})
MATCH (cma:CriticalMaterialAttribute)
MERGE (risk)-[:ASSESSES]->(cma);

// ---------------------------------------------------------------------------
// Analytical methods and stability evidence
// ---------------------------------------------------------------------------
UNWIND [
  {id: 'AM-HPLC-CU-001', name: 'HPLC assay and content uniformity method', type: 'HPLC', cqaIds: ['CQA-CONTENT-UNIFORMITY'], status: 'Validated for demonstration'},
  {id: 'AM-DISS-001', name: 'USP dissolution method', type: 'Dissolution', cqaIds: ['CQA-DISSOLUTION'], status: 'Validated for demonstration'},
  {id: 'AM-HARD-001', name: 'Tablet hardness test method', type: 'Physical test', cqaIds: ['CQA-TABLET-HARDNESS'], status: 'Qualified'},
  {id: 'AM-FRIAB-001', name: 'Tablet friability test method', type: 'Physical test', cqaIds: ['CQA-FRIABILITY'], status: 'Qualified'},
  {id: 'AM-NIR-PAT-001', name: 'Inline NIR blend uniformity PAT method', type: 'PAT model', cqaIds: ['CQA-BLEND-UNIFORMITY', 'CQA-CONTENT-UNIFORMITY'], status: 'Model validated for demonstration'}
] AS row
MERGE (method:AnalyticalMethod {methodId: row.id})
SET method.name = row.name,
    method.methodType = row.type,
    method.status = row.status,
    method.lifecycleState = 'Current'
WITH row, method
UNWIND row.cqaIds AS cqaId
MATCH (cqa:CQA {cqaId: cqaId})
MERGE (method)-[:MEASURES]->(cqa);

MATCH (cmc:CMCPackage {cmcPackageId: 'CMC-NCL-CDC-10MG-001'})
MATCH (method:AnalyticalMethod)
MERGE (cmc)-[:INCLUDES]->(method);

MATCH (product:Product {productId: 'PROD-NCL-CDC-TAB-10MG'})
MERGE (stability:StabilityStudy {stabilityStudyId: 'STAB-NCL-CDC-10MG-001'})
SET stability.name = 'NCL-CDC-Tablet-10mg accelerated and long-term stability protocol',
    stability.studyType = 'ICH stability protocol demo',
    stability.conditions = '25C/60%RH long-term; 40C/75%RH accelerated',
    stability.status = 'Ongoing demo',
    stability.startDate = date('2026-05-20')
MERGE (stability)-[:STUDIES]->(product);

MATCH (cmc:CMCPackage {cmcPackageId: 'CMC-NCL-CDC-10MG-001'})
MATCH (stability:StabilityStudy {stabilityStudyId: 'STAB-NCL-CDC-10MG-001'})
MERGE (cmc)-[:INCLUDES]->(stability);

MATCH (stability:StabilityStudy {stabilityStudyId: 'STAB-NCL-CDC-10MG-001'})
MATCH (cqa:CQA)
WHERE cqa.cqaId IN ['CQA-DISSOLUTION', 'CQA-CONTENT-UNIFORMITY', 'CQA-FRIABILITY']
MERGE (stability)-[:MONITORS]->(cqa);

// ---------------------------------------------------------------------------
// ISO/GMP-inspired QMS controls: SOPs, training, qualification, CSV
// ---------------------------------------------------------------------------
UNWIND [
  {id: 'SOP-CDC-LINE-001', title: 'Operation of CDC Line 1', process: 'Manufacturing operations'},
  {id: 'SOP-CDC-PAT-001', title: 'NIR PAT model monitoring and response', process: 'PAT and process monitoring'},
  {id: 'SOP-CDC-DEVIATION-001', title: 'CDC deviation triage and impact assessment', process: 'Quality event management'},
  {id: 'SOP-CDC-DATA-001', title: 'CDC historian data review and audit trail verification', process: 'Data integrity'}
] AS row
MERGE (sop:SOP {sopId: row.id})
SET sop.title = row.title,
    sop.processArea = row.process,
    sop.status = 'Effective',
    sop.effectiveDate = date('2026-05-01'),
    sop.standardContext = 'ISO 9001/Q10/GMP-inspired demo control'
WITH sop, row
MATCH (cmc:CMCPackage {cmcPackageId: 'CMC-NCL-CDC-10MG-001'})
MERGE (cmc)-[:REFERENCES_SOP]->(sop);

MATCH (sop:SOP {sopId: 'SOP-CDC-LINE-001'})
MATCH (recipe:Recipe {recipeId: 'REC-NCL-CDC-DC-001'})
MERGE (sop)-[:GOVERNS_RECIPE]->(recipe);

MATCH (sop:SOP {sopId: 'SOP-CDC-DEVIATION-001'})
MATCH (dev:Deviation {deviationId: 'DEV-CDC-20260601-001'})
MERGE (dev)-[:HANDLED_UNDER]->(sop);

MATCH (sop:SOP {sopId: 'SOP-CDC-DATA-001'})
MATCH (br:BatchRecord {batchRecordId: 'BR-NCLCDC10-260601'})
MERGE (br)-[:REVIEWED_UNDER]->(sop);

UNWIND [
  {id: 'TRN-OP001-CDC-LINE', operatorId: 'OP-001', sopId: 'SOP-CDC-LINE-001', completedAt: date('2026-05-10')},
  {id: 'TRN-OP002-PAT', operatorId: 'OP-002', sopId: 'SOP-CDC-PAT-001', completedAt: date('2026-05-12')},
  {id: 'TRN-OP003-QA-DEV', operatorId: 'OP-003', sopId: 'SOP-CDC-DEVIATION-001', completedAt: date('2026-05-11')},
  {id: 'TRN-OP003-DATA', operatorId: 'OP-003', sopId: 'SOP-CDC-DATA-001', completedAt: date('2026-05-11')}
] AS row
MATCH (op:Operator {operatorId: row.operatorId})
MATCH (sop:SOP {sopId: row.sopId})
MERGE (training:TrainingRecord {trainingRecordId: row.id})
SET training.completedAt = row.completedAt,
    training.status = 'Current',
    training.trainingType = 'SOP qualification'
MERGE (op)-[:HAS_TRAINING]->(training)
MERGE (training)-[:COVERS_SOP]->(sop);

UNWIND [
  {id: 'EQQUAL-FEEDERS-CDC01', name: 'CDC feeder train qualification', equipmentIds: ['EQ-FDR-API-001', 'EQ-FDR-EXC-001', 'EQ-FDR-LUB-001']},
  {id: 'EQQUAL-BLENDER-CDC01', name: 'Continuous blender qualification', equipmentIds: ['EQ-BLD-CONT-001']},
  {id: 'EQQUAL-PRESS-CDC01', name: 'Tablet press and checkweigher qualification', equipmentIds: ['EQ-PRESS-001', 'EQ-CHECK-001']},
  {id: 'EQQUAL-PAT-CDC01', name: 'NIR and force sensor qualification', equipmentIds: ['EQ-NIR-001', 'EQ-CFS-001', 'EQ-ENV-001']}
] AS row
MERGE (qualification:EquipmentQualification {equipmentQualificationId: row.id})
SET qualification.name = row.name,
    qualification.qualificationType = 'IQ/OQ/PQ demo package',
    qualification.status = 'Qualified',
    qualification.approvedAt = date('2026-05-18')
WITH row, qualification
UNWIND row.equipmentIds AS equipmentId
MATCH (equipment:Equipment {equipmentId: equipmentId})
MERGE (qualification)-[:QUALIFIES]->(equipment);

MATCH (cmc:CMCPackage {cmcPackageId: 'CMC-NCL-CDC-10MG-001'})
MATCH (qualification:EquipmentQualification)
MERGE (cmc)-[:INCLUDES]->(qualification);

UNWIND [
  {id: 'CSV-DCS-CDC01', name: 'CDC distributed control system validation', system: 'CDC-DCS-01'},
  {id: 'CSV-HIST-CDC01', name: 'CDC historian validation', system: 'CDC historian demo'},
  {id: 'CSV-EBR-CDC01', name: 'CDC electronic batch record validation', system: 'Electronic batch record demo'}
] AS row
MERGE (csv:ComputerSystemValidation {csvId: row.id})
SET csv.name = row.name,
    csv.systemName = row.system,
    csv.validationType = 'Computer system validation demo',
    csv.status = 'Validated for demonstration',
    csv.approvedAt = date('2026-05-19');

MATCH (cmc:CMCPackage {cmcPackageId: 'CMC-NCL-CDC-10MG-001'})
MATCH (csv:ComputerSystemValidation)
MERGE (cmc)-[:INCLUDES]->(csv);

MATCH (csv:ComputerSystemValidation {csvId: 'CSV-HIST-CDC01'})
MATCH (sensor:Sensor)
MERGE (csv)-[:VALIDATES_DATA_SOURCE]->(sensor);

// ---------------------------------------------------------------------------
// Change control and audit trail evidence
// ---------------------------------------------------------------------------
MERGE (change:ChangeControl {changeControlId: 'CC-CDC-NIR-MODEL-2026-001'})
SET change.title = 'NIR blend uniformity model update for CDC line 1',
    change.changeType = 'Analytical model change',
    change.status = 'Approved',
    change.openedAt = date('2026-05-02'),
    change.closedAt = date('2026-05-25'),
    change.impactSummary = 'Updates PAT model lifecycle evidence and confirms no adverse impact to CQA monitoring strategy.';

MATCH (change:ChangeControl {changeControlId: 'CC-CDC-NIR-MODEL-2026-001'})
MATCH (method:AnalyticalMethod {methodId: 'AM-NIR-PAT-001'})
MATCH (evidence:ValidationEvidence {evidenceId: 'VAL-PAT-NIR-001'})
MERGE (change)-[:CHANGES]->(method)
MERGE (change)-[:SUPPORTED_BY]->(evidence);

MATCH (cmc:CMCPackage {cmcPackageId: 'CMC-NCL-CDC-10MG-001'})
MATCH (change:ChangeControl {changeControlId: 'CC-CDC-NIR-MODEL-2026-001'})
MERGE (cmc)-[:INCLUDES]->(change);

UNWIND [
  {id: 'AUD-CDC-20260601-001', entityType: 'SensorReading', entityId: 'READ-NIR-BU-1020', action: 'Historian value captured', timestamp: '2026-06-01T10:20:00+01:00'},
  {id: 'AUD-CDC-20260601-002', entityType: 'Alarm', entityId: 'ALM-NIR-BU-20260601-001', action: 'Major alarm acknowledged', timestamp: '2026-06-01T10:24:00+01:00'},
  {id: 'AUD-CDC-20260601-003', entityType: 'Deviation', entityId: 'DEV-CDC-20260601-001', action: 'Deviation opened', timestamp: '2026-06-01T10:35:00+01:00'},
  {id: 'AUD-CDC-20260602-001', entityType: 'QAReleaseDecision', entityId: 'QA-REL-NCLCDC10-260601', action: 'QA release decision approved', timestamp: '2026-06-02T11:00:00+01:00'}
] AS row
MERGE (event:AuditTrailEvent {auditTrailEventId: row.id})
SET event.entityType = row.entityType,
    event.entityId = row.entityId,
    event.action = row.action,
    event.timestamp = datetime(row.timestamp),
    event.sourceSystem = 'CDC demo audit trail',
    event.dataIntegrityAttribute = 'Attributable, legible, contemporaneous, original, accurate demo evidence';

MATCH (event:AuditTrailEvent {auditTrailEventId: 'AUD-CDC-20260601-001'})
MATCH (reading:SensorReading {readingId: 'READ-NIR-BU-1020'})
MERGE (event)-[:DOCUMENTS]->(reading);

MATCH (event:AuditTrailEvent {auditTrailEventId: 'AUD-CDC-20260601-002'})
MATCH (alarm:Alarm {alarmId: 'ALM-NIR-BU-20260601-001'})
MERGE (event)-[:DOCUMENTS]->(alarm);

MATCH (event:AuditTrailEvent {auditTrailEventId: 'AUD-CDC-20260601-003'})
MATCH (dev:Deviation {deviationId: 'DEV-CDC-20260601-001'})
MERGE (event)-[:DOCUMENTS]->(dev);

MATCH (event:AuditTrailEvent {auditTrailEventId: 'AUD-CDC-20260602-001'})
MATCH (decision:QAReleaseDecision {decisionId: 'QA-REL-NCLCDC10-260601'})
MERGE (event)-[:DOCUMENTS]->(decision);

MATCH (br:BatchRecord {batchRecordId: 'BR-NCLCDC10-260601'})
MATCH (event:AuditTrailEvent)
MERGE (br)-[:HAS_AUDIT_TRAIL_EVENT]->(event);

// ---------------------------------------------------------------------------
// Process validation connects recipe, run, and validation evidence
// ---------------------------------------------------------------------------
MATCH (recipe:Recipe {recipeId: 'REC-NCL-CDC-DC-001'})
MATCH (run:ManufacturingRun {runId: 'RUN-CDC-2026-06-01-001'})
MATCH (evidence:ValidationEvidence {evidenceId: 'VAL-PPQ-CDC-001'})
MERGE (pv:ProcessValidation {processValidationId: 'PV-NCL-CDC-PPQ-001'})
SET pv.name = 'CDC process validation and PPQ demo package',
    pv.validationStage = 'PPQ demo',
    pv.status = 'Approved for demonstration',
    pv.summary = 'Connects validated recipe, executed run evidence, CPP/CQA review, and batch disposition.'
MERGE (pv)-[:VALIDATES]->(recipe)
MERGE (pv)-[:USES_RUN_EVIDENCE]->(run)
MERGE (pv)-[:SUPPORTED_BY]->(evidence);

MATCH (cmc:CMCPackage {cmcPackageId: 'CMC-NCL-CDC-10MG-001'})
MATCH (pv:ProcessValidation {processValidationId: 'PV-NCL-CDC-PPQ-001'})
MERGE (cmc)-[:INCLUDES]->(pv);
