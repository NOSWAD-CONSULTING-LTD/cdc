// Reference/master data for a CDC tablet manufacturing knowledge graph.
// This file is idempotent: all nodes and relationships use MERGE.

// ---------------------------------------------------------------------------
// Product, formulation, materials, and suppliers
// ---------------------------------------------------------------------------
MERGE (product:Product {productId: 'PROD-AZD-CDC-TAB-10MG'})
SET product.name = 'AZD-CDC-Tablet-10mg',
    product.dosageForm = 'Immediate release tablet',
    product.strength = '10 mg',
    product.route = 'Oral',
    product.lifecycleStage = 'Process performance qualification demo',
    product.description = 'Demo continuous direct compression tablet product';

MERGE (formulation:Formulation {formulationId: 'FORM-AZD-CDC-10MG-F001'})
SET formulation.name = 'AZD-CDC 10 mg direct compression formulation',
    formulation.version = 'F001',
    formulation.batchBasis = '100 kg theoretical blend',
    formulation.unitDoseTargetMg = 200.0,
    formulation.status = 'Approved for demonstration';

MATCH (product:Product {productId: 'PROD-AZD-CDC-TAB-10MG'})
MATCH (formulation:Formulation {formulationId: 'FORM-AZD-CDC-10MG-F001'})
MERGE (product)-[:HAS_FORMULATION {effectiveFrom: date('2026-01-01')}]->(formulation);

UNWIND [
  {id: 'SUP-AZ-API', name: 'AstraZeneca API Supply Network', type: 'Internal', country: 'GB', qualificationStatus: 'Qualified'},
  {id: 'SUP-DC-EXC', name: 'DirectComp Excipients Ltd', type: 'External', country: 'IE', qualificationStatus: 'Qualified'},
  {id: 'SUP-LUBE', name: 'Pharma Lubricants GmbH', type: 'External', country: 'DE', qualificationStatus: 'Qualified'}
] AS row
MERGE (s:Supplier {supplierId: row.id})
SET s.name = row.name,
    s.supplierType = row.type,
    s.country = row.country,
    s.qualificationStatus = row.qualificationStatus;

UNWIND [
  {id: 'MAT-AZD-API-10', name: 'AZD active pharmaceutical ingredient', role: 'API', grade: 'Micronized direct compression grade', compendialStatus: 'In-house specification', percentWw: 5.0},
  {id: 'MAT-MCC-DC-102', name: 'Microcrystalline cellulose PH102', role: 'Filler/binder', grade: 'Direct compression', compendialStatus: 'Ph. Eur./USP', percentWw: 63.0},
  {id: 'MAT-LACTOSE-SD', name: 'Spray dried lactose monohydrate', role: 'Filler', grade: 'Direct compression', compendialStatus: 'Ph. Eur./USP', percentWw: 25.0},
  {id: 'MAT-CCS', name: 'Croscarmellose sodium', role: 'Disintegrant', grade: 'Pharmaceutical', compendialStatus: 'Ph. Eur./USP', percentWw: 5.0},
  {id: 'MAT-MG-STEARATE', name: 'Magnesium stearate', role: 'Lubricant', grade: 'Vegetable origin', compendialStatus: 'Ph. Eur./USP', percentWw: 2.0}
] AS row
MATCH (formulation:Formulation {formulationId: 'FORM-AZD-CDC-10MG-F001'})
MERGE (m:Material {materialId: row.id})
SET m.name = row.name,
    m.materialRole = row.role,
    m.grade = row.grade,
    m.compendialStatus = row.compendialStatus,
    m.targetPercentWw = row.percentWw
MERGE (formulation)-[r:USES_MATERIAL]->(m)
SET r.targetPercentWw = row.percentWw,
    r.function = row.role;

MATCH (api:Material {materialId: 'MAT-AZD-API-10'}), (apiSup:Supplier {supplierId: 'SUP-AZ-API'})
MERGE (api)-[:QUALIFIED_SUPPLIER]->(apiSup);
MATCH (mcc:Material {materialId: 'MAT-MCC-DC-102'}), (excSup:Supplier {supplierId: 'SUP-DC-EXC'})
MERGE (mcc)-[:QUALIFIED_SUPPLIER]->(excSup);
MATCH (lac:Material {materialId: 'MAT-LACTOSE-SD'}), (excSup:Supplier {supplierId: 'SUP-DC-EXC'})
MERGE (lac)-[:QUALIFIED_SUPPLIER]->(excSup);
MATCH (ccs:Material {materialId: 'MAT-CCS'}), (excSup:Supplier {supplierId: 'SUP-DC-EXC'})
MERGE (ccs)-[:QUALIFIED_SUPPLIER]->(excSup);
MATCH (lub:Material {materialId: 'MAT-MG-STEARATE'}), (lubSup:Supplier {supplierId: 'SUP-LUBE'})
MERGE (lub)-[:QUALIFIED_SUPPLIER]->(lubSup);

// ---------------------------------------------------------------------------
// Site, line, rooms, equipment, sensors, and instruments
// ---------------------------------------------------------------------------
MERGE (site:ManufacturingSite {siteId: 'SITE-CDC-CAMBRIDGE-01'})
SET site.name = 'Cambridge CDC Demonstration Facility',
    site.country = 'GB',
    site.timezone = 'Europe/London',
    site.gmpStatus = 'Demo GMP-like architecture';

MERGE (line:ManufacturingLine {lineId: 'LINE-CDC-01'})
SET line.name = 'Continuous Direct Compression Line 1',
    line.controlSystem = 'CDC-DCS-01',
    line.status = 'Available',
    line.nominalThroughputKgPerHour = 25.0;

MATCH (site:ManufacturingSite {siteId: 'SITE-CDC-CAMBRIDGE-01'})
MATCH (line:ManufacturingLine {lineId: 'LINE-CDC-01'})
MERGE (site)-[:HAS_LINE]->(line);

UNWIND [
  {id: 'ROOM-FEED-101', name: 'Feeder suite 101', classification: 'ISO 8', humiditySetpointPct: 35.0},
  {id: 'ROOM-BLEND-102', name: 'Continuous blending suite 102', classification: 'ISO 8', humiditySetpointPct: 35.0},
  {id: 'ROOM-COMP-103', name: 'Compression suite 103', classification: 'ISO 8', humiditySetpointPct: 35.0},
  {id: 'ROOM-COLLECT-104', name: 'Finished tablet collection 104', classification: 'ISO 8', humiditySetpointPct: 35.0}
] AS row
MATCH (line:ManufacturingLine {lineId: 'LINE-CDC-01'})
MERGE (room:Room {roomId: row.id})
SET room.name = row.name,
    room.cleanroomClassification = row.classification,
    room.relativeHumiditySetpointPct = row.humiditySetpointPct
MERGE (line)-[:HAS_ROOM]->(room);

UNWIND [
  {id: 'EQ-FDR-API-001', name: 'API loss-in-weight feeder', type: 'Loss-in-weight feeder', model: 'LIW-20-Micro', serial: 'LIW20-001', roomId: 'ROOM-FEED-101'},
  {id: 'EQ-FDR-EXC-001', name: 'Excipient feeder', type: 'Loss-in-weight feeder', model: 'LIW-50-Pharma', serial: 'LIW50-011', roomId: 'ROOM-FEED-101'},
  {id: 'EQ-FDR-LUB-001', name: 'Lubricant feeder', type: 'Loss-in-weight feeder', model: 'LIW-5-Micro', serial: 'LIW5-003', roomId: 'ROOM-BLEND-102'},
  {id: 'EQ-BLD-CONT-001', name: 'Continuous blender', type: 'Continuous blender', model: 'CB-1000', serial: 'CB1000-018', roomId: 'ROOM-BLEND-102'},
  {id: 'EQ-PRESS-001', name: 'Tablet press', type: 'Rotary tablet press', model: 'RTP-36', serial: 'RTP36-204', roomId: 'ROOM-COMP-103'},
  {id: 'EQ-CHECK-001', name: 'Checkweigher', type: 'In-process checkweigher', model: 'IPC-WT-12', serial: 'IPC12-067', roomId: 'ROOM-COMP-103'},
  {id: 'EQ-NIR-001', name: 'NIR sensor', type: 'PAT instrument', model: 'NIR-Blend-Inline', serial: 'NIRB-908', roomId: 'ROOM-BLEND-102'},
  {id: 'EQ-CFS-001', name: 'Compression force sensor', type: 'Press force transducer', model: 'CFS-36', serial: 'CFS36-142', roomId: 'ROOM-COMP-103'},
  {id: 'EQ-ENV-001', name: 'Environmental sensor', type: 'Room environmental transmitter', model: 'RHT-900', serial: 'RHT900-451', roomId: 'ROOM-COMP-103'}
] AS row
MATCH (line:ManufacturingLine {lineId: 'LINE-CDC-01'})
MATCH (room:Room {roomId: row.roomId})
MERGE (eq:Equipment {equipmentId: row.id})
SET eq.name = row.name,
    eq.equipmentType = row.type,
    eq.model = row.model,
    eq.serialNumber = row.serial,
    eq.status = 'Qualified'
MERGE (eq)-[:LOCATED_IN]->(room)
MERGE (line)-[:INCLUDES_EQUIPMENT]->(eq);

UNWIND [
  {id: 'SENS-API-FEED-RATE', name: 'API feeder mass flow', type: 'Feeder controller PV', unit: 'kg/h', equipmentId: 'EQ-FDR-API-001'},
  {id: 'SENS-EXC-FEED-RATE', name: 'Excipient feeder mass flow', type: 'Feeder controller PV', unit: 'kg/h', equipmentId: 'EQ-FDR-EXC-001'},
  {id: 'SENS-LUB-FEED-RATE', name: 'Lubricant feeder mass flow', type: 'Feeder controller PV', unit: 'kg/h', equipmentId: 'EQ-FDR-LUB-001'},
  {id: 'SENS-BLENDER-SPEED', name: 'Blender impeller speed', type: 'Drive speed PV', unit: 'rpm', equipmentId: 'EQ-BLD-CONT-001'},
  {id: 'SENS-RESIDENCE-TIME', name: 'Calculated residence time', type: 'Soft sensor', unit: 's', equipmentId: 'EQ-BLD-CONT-001'},
  {id: 'SENS-NIR-BU', name: 'Inline NIR blend uniformity', type: 'PAT NIR prediction', unit: '%RSD', equipmentId: 'EQ-NIR-001'},
  {id: 'SENS-COMPRESSION-FORCE', name: 'Main compression force', type: 'Force transducer', unit: 'kN', equipmentId: 'EQ-CFS-001'},
  {id: 'SENS-TURRET-SPEED', name: 'Tablet press turret speed', type: 'Drive speed PV', unit: 'rpm', equipmentId: 'EQ-PRESS-001'},
  {id: 'SENS-TABLET-WEIGHT', name: 'In-process tablet weight', type: 'Checkweigher', unit: 'mg', equipmentId: 'EQ-CHECK-001'},
  {id: 'SENS-ROOM-RH', name: 'Compression room relative humidity', type: 'Environmental transmitter', unit: '%RH', equipmentId: 'EQ-ENV-001'}
] AS row
MATCH (eq:Equipment {equipmentId: row.equipmentId})
MERGE (s:Sensor {sensorId: row.id})
SET s.name = row.name,
    s.sensorType = row.type,
    s.unit = row.unit,
    s.dataHistorianTag = 'CDC01.' + row.id
MERGE (eq)-[:HAS_SENSOR]->(s);

// ---------------------------------------------------------------------------
// Recipe and ordered process steps
// ---------------------------------------------------------------------------
MERGE (recipe:Recipe {recipeId: 'REC-AZD-CDC-DC-001'})
SET recipe.name = 'Direct compression tablet process',
    recipe.version = '1.0',
    recipe.processType = 'Continuous Direct Compression',
    recipe.status = 'Approved',
    recipe.nominalThroughputKgPerHour = 25.0;

MATCH (product:Product {productId: 'PROD-AZD-CDC-TAB-10MG'})
MATCH (recipe:Recipe {recipeId: 'REC-AZD-CDC-DC-001'})
MERGE (product)-[:HAS_RECIPE]->(recipe);

UNWIND [
  {id: 'STEP-001-API-FEED', order: 1, name: 'API feeding', description: 'Meter micronized API into the continuous process stream.', equipmentIds: ['EQ-FDR-API-001']},
  {id: 'STEP-002-EXC-FEED', order: 2, name: 'Excipient feeding', description: 'Meter filler, binder, and disintegrant excipients.', equipmentIds: ['EQ-FDR-EXC-001']},
  {id: 'STEP-003-CONT-BLEND', order: 3, name: 'Continuous blending', description: 'Blend API and excipients under controlled residence time.', equipmentIds: ['EQ-BLD-CONT-001', 'EQ-NIR-001']},
  {id: 'STEP-004-LUB-ADD', order: 4, name: 'Lubricant addition', description: 'Add magnesium stearate downstream to avoid over-lubrication.', equipmentIds: ['EQ-FDR-LUB-001', 'EQ-BLD-CONT-001']},
  {id: 'STEP-005-COMPRESS', order: 5, name: 'Tablet compression', description: 'Compress blend into 200 mg immediate release tablets.', equipmentIds: ['EQ-PRESS-001', 'EQ-CFS-001']},
  {id: 'STEP-006-WEIGHT-CTRL', order: 6, name: 'In-process weight control', description: 'Monitor tablet weight and support press control actions.', equipmentIds: ['EQ-CHECK-001']},
  {id: 'STEP-007-COLLECT', order: 7, name: 'Finished tablet collection', description: 'Collect accepted tablets into labelled bulk containers.', equipmentIds: ['EQ-CHECK-001']}
] AS row
MATCH (recipe:Recipe {recipeId: 'REC-AZD-CDC-DC-001'})
MERGE (step:ProcessStep {stepId: row.id})
SET step.name = row.name,
    step.stepOrder = row.order,
    step.description = row.description,
    step.processMode = 'Continuous'
MERGE (recipe)-[defines:DEFINES_STEP]->(step)
SET defines.stepOrder = row.order
WITH row, step
UNWIND row.equipmentIds AS equipmentId
MATCH (eq:Equipment {equipmentId: equipmentId})
MERGE (step)-[:USES_EQUIPMENT]->(eq);

MATCH (s1:ProcessStep {stepId: 'STEP-001-API-FEED'}), (s2:ProcessStep {stepId: 'STEP-002-EXC-FEED'})
MERGE (s1)-[:NEXT_STEP]->(s2);
MATCH (s2:ProcessStep {stepId: 'STEP-002-EXC-FEED'}), (s3:ProcessStep {stepId: 'STEP-003-CONT-BLEND'})
MERGE (s2)-[:NEXT_STEP]->(s3);
MATCH (s3:ProcessStep {stepId: 'STEP-003-CONT-BLEND'}), (s4:ProcessStep {stepId: 'STEP-004-LUB-ADD'})
MERGE (s3)-[:NEXT_STEP]->(s4);
MATCH (s4:ProcessStep {stepId: 'STEP-004-LUB-ADD'}), (s5:ProcessStep {stepId: 'STEP-005-COMPRESS'})
MERGE (s4)-[:NEXT_STEP]->(s5);
MATCH (s5:ProcessStep {stepId: 'STEP-005-COMPRESS'}), (s6:ProcessStep {stepId: 'STEP-006-WEIGHT-CTRL'})
MERGE (s5)-[:NEXT_STEP]->(s6);
MATCH (s6:ProcessStep {stepId: 'STEP-006-WEIGHT-CTRL'}), (s7:ProcessStep {stepId: 'STEP-007-COLLECT'})
MERGE (s6)-[:NEXT_STEP]->(s7);

// ---------------------------------------------------------------------------
// CPPs, CQAs, specifications, and measurement semantics
// ---------------------------------------------------------------------------
UNWIND [
  {id: 'CPP-API-FEED-RATE', name: 'API feed rate', unit: 'kg/h', target: 1.25, low: 1.19, high: 1.31, stepId: 'STEP-001-API-FEED', sensorId: 'SENS-API-FEED-RATE'},
  {id: 'CPP-EXC-FEED-RATE', name: 'Excipient feed rate', unit: 'kg/h', target: 23.25, low: 22.55, high: 23.95, stepId: 'STEP-002-EXC-FEED', sensorId: 'SENS-EXC-FEED-RATE'},
  {id: 'CPP-LUB-FEED-RATE', name: 'Lubricant feed rate', unit: 'kg/h', target: 0.50, low: 0.47, high: 0.53, stepId: 'STEP-004-LUB-ADD', sensorId: 'SENS-LUB-FEED-RATE'},
  {id: 'CPP-BLENDER-SPEED', name: 'Blender speed', unit: 'rpm', target: 180.0, low: 165.0, high: 195.0, stepId: 'STEP-003-CONT-BLEND', sensorId: 'SENS-BLENDER-SPEED'},
  {id: 'CPP-RESIDENCE-TIME', name: 'Residence time', unit: 's', target: 90.0, low: 75.0, high: 110.0, stepId: 'STEP-003-CONT-BLEND', sensorId: 'SENS-RESIDENCE-TIME'},
  {id: 'CPP-COMPRESSION-FORCE', name: 'Compression force', unit: 'kN', target: 12.0, low: 10.5, high: 13.5, stepId: 'STEP-005-COMPRESS', sensorId: 'SENS-COMPRESSION-FORCE'},
  {id: 'CPP-TURRET-SPEED', name: 'Turret speed', unit: 'rpm', target: 45.0, low: 38.0, high: 52.0, stepId: 'STEP-005-COMPRESS', sensorId: 'SENS-TURRET-SPEED'},
  {id: 'CPP-ROOM-HUMIDITY', name: 'Room humidity', unit: '%RH', target: 35.0, low: 25.0, high: 45.0, stepId: 'STEP-005-COMPRESS', sensorId: 'SENS-ROOM-RH'}
] AS row
MATCH (step:ProcessStep {stepId: row.stepId})
MATCH (sensor:Sensor {sensorId: row.sensorId})
MERGE (cpp:CPP {cppId: row.id})
SET cpp.name = row.name,
    cpp.unit = row.unit,
    cpp.targetValue = row.target,
    cpp.lowerLimit = row.low,
    cpp.upperLimit = row.high,
    cpp.controlStrategy = 'Automated monitoring with operator review on excursion'
MERGE (cpp)-[:CONTROLS]->(step)
MERGE (sensor)-[:MEASURES]->(cpp);

UNWIND [
  {id: 'CQA-BLEND-UNIFORMITY', name: 'Blend uniformity', unit: '%RSD', target: 3.0, low: 0.0, high: 5.0, sensorId: 'SENS-NIR-BU'},
  {id: 'CQA-TABLET-WEIGHT', name: 'Tablet weight', unit: 'mg', target: 200.0, low: 190.0, high: 210.0, sensorId: 'SENS-TABLET-WEIGHT'},
  {id: 'CQA-TABLET-HARDNESS', name: 'Tablet hardness', unit: 'kp', target: 8.0, low: 6.0, high: 10.0, sensorId: 'SENS-COMPRESSION-FORCE'},
  {id: 'CQA-CONTENT-UNIFORMITY', name: 'Content uniformity', unit: '% label claim', target: 100.0, low: 85.0, high: 115.0, sensorId: 'SENS-NIR-BU'},
  {id: 'CQA-DISSOLUTION', name: 'Dissolution', unit: '% dissolved at 30 min', target: 85.0, low: 80.0, high: 100.0, sensorId: 'SENS-NIR-BU'},
  {id: 'CQA-FRIABILITY', name: 'Friability', unit: '% weight loss', target: 0.3, low: 0.0, high: 1.0, sensorId: 'SENS-COMPRESSION-FORCE'}
] AS row
MATCH (sensor:Sensor {sensorId: row.sensorId})
MERGE (cqa:CQA {cqaId: row.id})
SET cqa.name = row.name,
    cqa.unit = row.unit,
    cqa.targetValue = row.target,
    cqa.patientImpact = 'Potential quality attribute for tablet performance'
MERGE (spec:Specification {specificationId: 'SPEC-' + row.id})
SET spec.name = row.name + ' specification',
    spec.specificationType = 'CQA acceptance criterion',
    spec.lowerLimit = row.low,
    spec.upperLimit = row.high,
    spec.targetValue = row.target,
    spec.unit = row.unit,
    spec.effectiveFrom = date('2026-01-01'),
    spec.status = 'Approved'
MERGE (cqa)-[:HAS_SPECIFICATION]->(spec)
MERGE (sensor)-[:MEASURES]->(cqa);

UNWIND [
  {cppId: 'CPP-API-FEED-RATE', cqaId: 'CQA-BLEND-UNIFORMITY', rationale: 'API mass flow variability can drive local potency variation.'},
  {cppId: 'CPP-API-FEED-RATE', cqaId: 'CQA-CONTENT-UNIFORMITY', rationale: 'API delivery variation directly affects unit-dose content.'},
  {cppId: 'CPP-EXC-FEED-RATE', cqaId: 'CQA-TABLET-WEIGHT', rationale: 'Excipient stream dominates total blend mass flow.'},
  {cppId: 'CPP-BLENDER-SPEED', cqaId: 'CQA-BLEND-UNIFORMITY', rationale: 'Mixing intensity affects blend homogeneity.'},
  {cppId: 'CPP-RESIDENCE-TIME', cqaId: 'CQA-BLEND-UNIFORMITY', rationale: 'Residence time distribution affects mixing completeness.'},
  {cppId: 'CPP-LUB-FEED-RATE', cqaId: 'CQA-DISSOLUTION', rationale: 'Over-lubrication may slow disintegration and dissolution.'},
  {cppId: 'CPP-LUB-FEED-RATE', cqaId: 'CQA-FRIABILITY', rationale: 'Lubrication affects tablet mechanical robustness.'},
  {cppId: 'CPP-COMPRESSION-FORCE', cqaId: 'CQA-TABLET-HARDNESS', rationale: 'Compression force is a primary hardness driver.'},
  {cppId: 'CPP-COMPRESSION-FORCE', cqaId: 'CQA-DISSOLUTION', rationale: 'Higher compaction can reduce dissolution rate.'},
  {cppId: 'CPP-TURRET-SPEED', cqaId: 'CQA-TABLET-WEIGHT', rationale: 'Press speed can affect die fill consistency.'},
  {cppId: 'CPP-ROOM-HUMIDITY', cqaId: 'CQA-BLEND-UNIFORMITY', rationale: 'Humidity can influence powder flow and feeding stability.'},
  {cppId: 'CPP-ROOM-HUMIDITY', cqaId: 'CQA-TABLET-HARDNESS', rationale: 'Moisture can alter compaction behavior.'}
] AS row
MATCH (cpp:CPP {cppId: row.cppId})
MATCH (cqa:CQA {cqaId: row.cqaId})
MERGE (cpp)-[r:IMPACTS]->(cqa)
SET r.rationale = row.rationale,
    r.impactAssessment = 'Production-inspired demo knowledge';

// ---------------------------------------------------------------------------
// Cleaning, calibration, operators, regulatory filing, and validation evidence
// ---------------------------------------------------------------------------
UNWIND [
  {id: 'OP-001', name: 'Priya Shah', role: 'Manufacturing operator', qualification: 'CDC line trained'},
  {id: 'OP-002', name: 'Marcus Evans', role: 'Automation engineer', qualification: 'Historian and PAT trained'},
  {id: 'OP-003', name: 'Elena Rossi', role: 'QA reviewer', qualification: 'Batch disposition trained'}
] AS row
MERGE (op:Operator {operatorId: row.id})
SET op.name = row.name,
    op.role = row.role,
    op.qualification = row.qualification;

UNWIND [
  {id: 'CLEAN-CDC01-2026-05-31', lineId: 'LINE-CDC-01', status: 'Accepted', cleanedAt: datetime('2026-05-31T18:30:00+01:00'), method: 'Line clearance and product-contact clean'},
  {id: 'CLEAN-CDC01-2026-06-01', lineId: 'LINE-CDC-01', status: 'Accepted', cleanedAt: datetime('2026-06-01T22:00:00+01:00'), method: 'Post-run product-contact clean'}
] AS row
MATCH (line:ManufacturingLine {lineId: row.lineId})
MERGE (cr:CleaningRecord {cleaningRecordId: row.id})
SET cr.status = row.status,
    cr.cleanedAt = row.cleanedAt,
    cr.method = row.method
MERGE (cr)-[:COVERS_LINE]->(line);

UNWIND [
  {id: 'CAL-NIR-2026-05', equipmentId: 'EQ-NIR-001', status: 'In tolerance', calibratedAt: date('2026-05-20'), dueDate: date('2026-06-20')},
  {id: 'CAL-CFS-2026-05', equipmentId: 'EQ-CFS-001', status: 'In tolerance', calibratedAt: date('2026-05-22'), dueDate: date('2026-06-22')},
  {id: 'CAL-CHECK-2026-05', equipmentId: 'EQ-CHECK-001', status: 'In tolerance', calibratedAt: date('2026-05-21'), dueDate: date('2026-06-21')},
  {id: 'CAL-ENV-2026-05', equipmentId: 'EQ-ENV-001', status: 'In tolerance', calibratedAt: date('2026-05-18'), dueDate: date('2026-06-18')}
] AS row
MATCH (eq:Equipment {equipmentId: row.equipmentId})
MERGE (cal:CalibrationRecord {calibrationRecordId: row.id})
SET cal.status = row.status,
    cal.calibratedAt = row.calibratedAt,
    cal.dueDate = row.dueDate
MERGE (cal)-[:CALIBRATES]->(eq);

MERGE (filing:RegulatoryFiling {filingId: 'REG-FILING-AZD-CDC-DEMO-001'})
SET filing.name = 'AZD-CDC-Tablet-10mg Module 3 demo filing',
    filing.region = 'Demo global',
    filing.status = 'Reference architecture evidence package',
    filing.submissionType = 'CMC continuous manufacturing demonstration',
    filing.submissionDate = date('2026-05-15');

MATCH (filing:RegulatoryFiling {filingId: 'REG-FILING-AZD-CDC-DEMO-001'})
MATCH (product:Product {productId: 'PROD-AZD-CDC-TAB-10MG'})
MERGE (filing)-[:COVERS]->(product);

UNWIND [
  {id: 'VAL-PPQ-CDC-001', name: 'CDC process performance qualification protocol', type: 'PPQ protocol', status: 'Approved', summary: 'Defines continuous run acceptance strategy and batch genealogy controls.'},
  {id: 'VAL-PAT-NIR-001', name: 'NIR blend uniformity model validation', type: 'PAT model validation', status: 'Approved', summary: 'Supports inline prediction of blend uniformity and content risk.'},
  {id: 'VAL-CS-CDC-001', name: 'CDC control strategy report', type: 'Control strategy', status: 'Approved', summary: 'Links CPP monitoring, CQA risk, alarms, and disposition evidence.'},
  {id: 'VAL-DATA-INTEG-001', name: 'Manufacturing data integrity assessment', type: 'Data integrity', status: 'Approved', summary: 'Defines traceability from historian readings to batch record review.'}
] AS row
MATCH (filing:RegulatoryFiling {filingId: 'REG-FILING-AZD-CDC-DEMO-001'})
MERGE (ev:ValidationEvidence {evidenceId: row.id})
SET ev.name = row.name,
    ev.evidenceType = row.type,
    ev.status = row.status,
    ev.summary = row.summary,
    ev.effectiveDate = date('2026-05-01')
MERGE (ev)-[:SUPPORTS]->(filing);
