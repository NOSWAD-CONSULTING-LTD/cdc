// Example CDC manufacturing run with material genealogy, readings, alarm,
// deviation, batch record, and QA release decision.
// This file is idempotent and assumes 01_constraints and 02_seed_reference_data ran.

// ---------------------------------------------------------------------------
// Material lots consumed by the run
// ---------------------------------------------------------------------------
UNWIND [
  {lotId: 'LOT-API-AZD-240501-A', lotNumber: 'API-AZD-240501-A', materialId: 'MAT-AZD-API-10', supplierId: 'SUP-AZ-API', coaStatus: 'Accepted', receivedAt: date('2026-05-10'), expiryDate: date('2028-05-01'), quantityKg: 6.0},
  {lotId: 'LOT-MCC-260430-17', lotNumber: 'MCC-260430-17', materialId: 'MAT-MCC-DC-102', supplierId: 'SUP-DC-EXC', coaStatus: 'Accepted', receivedAt: date('2026-05-12'), expiryDate: date('2029-04-30'), quantityKg: 70.0},
  {lotId: 'LOT-LACTOSE-260415-09', lotNumber: 'LAC-260415-09', materialId: 'MAT-LACTOSE-SD', supplierId: 'SUP-DC-EXC', coaStatus: 'Accepted', receivedAt: date('2026-05-12'), expiryDate: date('2028-04-15'), quantityKg: 30.0},
  {lotId: 'LOT-CCS-260421-05', lotNumber: 'CCS-260421-05', materialId: 'MAT-CCS', supplierId: 'SUP-DC-EXC', coaStatus: 'Accepted', receivedAt: date('2026-05-13'), expiryDate: date('2028-04-21'), quantityKg: 8.0},
  {lotId: 'LOT-MGST-260402-02', lotNumber: 'MGST-260402-02', materialId: 'MAT-MG-STEARATE', supplierId: 'SUP-LUBE', coaStatus: 'Accepted', receivedAt: date('2026-05-11'), expiryDate: date('2028-04-02'), quantityKg: 3.0}
] AS row
MATCH (mat:Material {materialId: row.materialId})
MATCH (sup:Supplier {supplierId: row.supplierId})
MERGE (lot:MaterialLot {lotId: row.lotId})
SET lot.lotNumber = row.lotNumber,
    lot.coaStatus = row.coaStatus,
    lot.receivedAt = row.receivedAt,
    lot.expiryDate = row.expiryDate,
    lot.quantityReceivedKg = row.quantityKg,
    lot.releaseStatus = 'Released for manufacturing'
MERGE (lot)-[:INSTANCE_OF]->(mat)
MERGE (lot)-[:SUPPLIED_BY]->(sup);

// ---------------------------------------------------------------------------
// Manufacturing run setup and batch record
// ---------------------------------------------------------------------------
MATCH (recipe:Recipe {recipeId: 'REC-AZD-CDC-DC-001'})
MATCH (site:ManufacturingSite {siteId: 'SITE-CDC-CAMBRIDGE-01'})
MATCH (line:ManufacturingLine {lineId: 'LINE-CDC-01'})
MERGE (run:ManufacturingRun {runId: 'RUN-CDC-2026-06-01-001'})
SET run.name = 'CDC demonstration run 2026-06-01',
    run.status = 'Released',
    run.mode = 'Continuous',
    run.batchNumber = 'AZDCDC10-260601',
    run.startTime = datetime('2026-06-01T08:00:00+01:00'),
    run.endTime = datetime('2026-06-01T14:30:00+01:00'),
    run.targetTabletCount = 500000,
    run.actualTabletCount = 497820,
    run.yieldPct = 99.1,
    run.disposition = 'Released'
MERGE (run)-[:EXECUTES]->(recipe)
MERGE (run)-[:AT_SITE]->(site)
MERGE (run)-[:USES_LINE]->(line);

MATCH (run:ManufacturingRun {runId: 'RUN-CDC-2026-06-01-001'})
MATCH (op1:Operator {operatorId: 'OP-001'})
MATCH (op2:Operator {operatorId: 'OP-002'})
MATCH (clean:CleaningRecord {cleaningRecordId: 'CLEAN-CDC01-2026-05-31'})
MERGE (br:BatchRecord {batchRecordId: 'BR-AZDCDC10-260601'})
SET br.batchNumber = 'AZDCDC10-260601',
    br.recordType = 'Electronic batch record',
    br.status = 'Reviewed',
    br.createdAt = datetime('2026-06-01T07:45:00+01:00'),
    br.reviewedAt = datetime('2026-06-02T10:15:00+01:00'),
    br.summary = 'Batch record includes line clearance, material genealogy, CPP trends, deviation assessment, and QA disposition.'
MERGE (run)-[:HAS_BATCH_RECORD]->(br)
MERGE (br)-[:SIGNED_BY {signatureMeaning: 'Performed by'}]->(op1)
MERGE (br)-[:SIGNED_BY {signatureMeaning: 'Automation review'}]->(op2)
MERGE (br)-[:REFERENCES_CLEANING]->(clean);

MATCH (run:ManufacturingRun {runId: 'RUN-CDC-2026-06-01-001'})
UNWIND [
  {lotId: 'LOT-API-AZD-240501-A', quantityKg: 5.08, purpose: 'API input stream'},
  {lotId: 'LOT-MCC-260430-17', quantityKg: 63.12, purpose: 'MCC excipient stream'},
  {lotId: 'LOT-LACTOSE-260415-09', quantityKg: 25.05, purpose: 'Lactose excipient stream'},
  {lotId: 'LOT-CCS-260421-05', quantityKg: 5.01, purpose: 'Disintegrant excipient stream'},
  {lotId: 'LOT-MGST-260402-02', quantityKg: 2.02, purpose: 'Lubricant stream'}
] AS row
MATCH (lot:MaterialLot {lotId: row.lotId})
MERGE (run)-[r:CONSUMES]->(lot)
SET r.quantityKg = row.quantityKg,
    r.purpose = row.purpose,
    r.consumptionWindowStart = datetime('2026-06-01T08:05:00+01:00'),
    r.consumptionWindowEnd = datetime('2026-06-01T14:10:00+01:00');

// Link run to calibration evidence for instruments used in the run.
MATCH (run:ManufacturingRun {runId: 'RUN-CDC-2026-06-01-001'})
UNWIND ['CAL-NIR-2026-05', 'CAL-CFS-2026-05', 'CAL-CHECK-2026-05', 'CAL-ENV-2026-05'] AS calId
MATCH (cal:CalibrationRecord {calibrationRecordId: calId})
MERGE (run)-[:USES_CALIBRATION]->(cal);

// ---------------------------------------------------------------------------
// Sensor readings. Values include both nominal and excursion examples.
// ---------------------------------------------------------------------------
UNWIND [
  {id: 'READ-API-FR-0800', sensorId: 'SENS-API-FEED-RATE', time: '2026-06-01T08:15:00+01:00', value: 1.24, unit: 'kg/h', target: 1.25, low: 1.19, high: 1.31, status: 'In specification'},
  {id: 'READ-EXC-FR-0800', sensorId: 'SENS-EXC-FEED-RATE', time: '2026-06-01T08:15:00+01:00', value: 23.31, unit: 'kg/h', target: 23.25, low: 22.55, high: 23.95, status: 'In specification'},
  {id: 'READ-BLD-SPD-0900', sensorId: 'SENS-BLENDER-SPEED', time: '2026-06-01T09:00:00+01:00', value: 181.0, unit: 'rpm', target: 180.0, low: 165.0, high: 195.0, status: 'In specification'},
  {id: 'READ-RES-TIME-0900', sensorId: 'SENS-RESIDENCE-TIME', time: '2026-06-01T09:00:00+01:00', value: 88.0, unit: 's', target: 90.0, low: 75.0, high: 110.0, status: 'In specification'},
  {id: 'READ-NIR-BU-0930', sensorId: 'SENS-NIR-BU', time: '2026-06-01T09:30:00+01:00', value: 3.2, unit: '%RSD', target: 3.0, low: 0.0, high: 5.0, status: 'In specification'},
  {id: 'READ-RH-1015', sensorId: 'SENS-ROOM-RH', time: '2026-06-01T10:15:00+01:00', value: 46.8, unit: '%RH', target: 35.0, low: 25.0, high: 45.0, status: 'Out of specification'},
  {id: 'READ-NIR-BU-1020', sensorId: 'SENS-NIR-BU', time: '2026-06-01T10:20:00+01:00', value: 5.6, unit: '%RSD', target: 3.0, low: 0.0, high: 5.0, status: 'Out of specification'},
  {id: 'READ-COMP-FORCE-1115', sensorId: 'SENS-COMPRESSION-FORCE', time: '2026-06-01T11:15:00+01:00', value: 12.4, unit: 'kN', target: 12.0, low: 10.5, high: 13.5, status: 'In specification'},
  {id: 'READ-TURRET-1115', sensorId: 'SENS-TURRET-SPEED', time: '2026-06-01T11:15:00+01:00', value: 45.5, unit: 'rpm', target: 45.0, low: 38.0, high: 52.0, status: 'In specification'},
  {id: 'READ-WEIGHT-1200', sensorId: 'SENS-TABLET-WEIGHT', time: '2026-06-01T12:00:00+01:00', value: 201.4, unit: 'mg', target: 200.0, low: 190.0, high: 210.0, status: 'In specification'},
  {id: 'READ-WEIGHT-1230', sensorId: 'SENS-TABLET-WEIGHT', time: '2026-06-01T12:30:00+01:00', value: 211.2, unit: 'mg', target: 200.0, low: 190.0, high: 210.0, status: 'Out of specification'},
  {id: 'READ-WEIGHT-1300', sensorId: 'SENS-TABLET-WEIGHT', time: '2026-06-01T13:00:00+01:00', value: 199.2, unit: 'mg', target: 200.0, low: 190.0, high: 210.0, status: 'In specification'}
] AS row
MATCH (sensor:Sensor {sensorId: row.sensorId})
MATCH (run:ManufacturingRun {runId: 'RUN-CDC-2026-06-01-001'})
MERGE (reading:SensorReading {readingId: row.id})
SET reading.timestamp = datetime(row.time),
    reading.value = row.value,
    reading.unit = row.unit,
    reading.targetValue = row.target,
    reading.lowerLimit = row.low,
    reading.upperLimit = row.high,
    reading.status = row.status,
    reading.sourceSystem = 'CDC historian demo'
MERGE (reading)-[:RECORDED_BY]->(sensor)
MERGE (reading)-[:DURING_RUN]->(run);

// Connect readings to their measured CPP or CQA targets for graph traversal.
MATCH (reading:SensorReading)-[:RECORDED_BY]->(sensor:Sensor)-[:MEASURES]->(measure)
WHERE reading.readingId STARTS WITH 'READ-'
MERGE (reading)-[:OBSERVES]->(measure);

// ---------------------------------------------------------------------------
// Alarm, deviation investigation, and QA release
// ---------------------------------------------------------------------------
MATCH (reading:SensorReading {readingId: 'READ-NIR-BU-1020'})
MERGE (alarm:Alarm {alarmId: 'ALM-NIR-BU-20260601-001'})
SET alarm.name = 'Blend uniformity high %RSD alarm',
    alarm.alarmCode = 'NIR_BU_HIGH',
    alarm.severity = 'Major',
    alarm.status = 'Closed',
    alarm.triggeredAt = datetime('2026-06-01T10:20:30+01:00'),
    alarm.limitValue = 5.0,
    alarm.operatorAction = 'Diverted affected material segment and initiated deviation.'
MERGE (alarm)-[:TRIGGERED_BY]->(reading);

MATCH (run:ManufacturingRun {runId: 'RUN-CDC-2026-06-01-001'})
MATCH (alarm:Alarm {alarmId: 'ALM-NIR-BU-20260601-001'})
MATCH (rhReading:SensorReading {readingId: 'READ-RH-1015'})
MATCH (qa:Operator {operatorId: 'OP-003'})
MERGE (dev:Deviation {deviationId: 'DEV-CDC-20260601-001'})
SET dev.title = 'Transient blend uniformity excursion during humidity drift',
    dev.deviationType = 'Process excursion',
    dev.severity = 'Major',
    dev.status = 'Closed',
    dev.openedAt = datetime('2026-06-01T10:35:00+01:00'),
    dev.closedAt = datetime('2026-06-02T09:30:00+01:00'),
    dev.rootCause = 'Transient room humidity excursion coincident with powder flow instability; affected segment diverted.',
    dev.impactAssessment = 'No released tablets from affected window. Subsequent CQA checks acceptable.',
    dev.capa = 'Tightened humidity alarm response and verified environmental sensor trend review in batch record.'
MERGE (run)-[:HAS_DEVIATION]->(dev)
MERGE (dev)-[:INVESTIGATES]->(alarm)
MERGE (dev)-[:CONSIDERS_READING]->(rhReading)
MERGE (dev)-[:APPROVED_BY]->(qa);

MATCH (br:BatchRecord {batchRecordId: 'BR-AZDCDC10-260601'})
MATCH (run:ManufacturingRun {runId: 'RUN-CDC-2026-06-01-001'})
MATCH (qa:Operator {operatorId: 'OP-003'})
MERGE (decision:QAReleaseDecision {decisionId: 'QA-REL-AZDCDC10-260601'})
SET decision.decision = 'Release',
    decision.status = 'Approved',
    decision.decidedAt = datetime('2026-06-02T11:00:00+01:00'),
    decision.rationale = 'Batch record complete; deviation closed with no impact to released material; CPP/CQA review acceptable after diversion.'
MERGE (decision)-[:REVIEWS]->(br)
MERGE (decision)-[:RELEASES]->(run)
MERGE (decision)-[:DECIDED_BY]->(qa);

// ---------------------------------------------------------------------------
// Second demonstration run with a rejected/quarantined disposition.
// This creates contrast for impact analysis and keeps both RELEASES and REJECTS
// relationship types present for Neo4j Browser visualisation examples.
// ---------------------------------------------------------------------------
MATCH (recipe:Recipe {recipeId: 'REC-AZD-CDC-DC-001'})
MATCH (site:ManufacturingSite {siteId: 'SITE-CDC-CAMBRIDGE-01'})
MATCH (line:ManufacturingLine {lineId: 'LINE-CDC-01'})
MERGE (run:ManufacturingRun {runId: 'RUN-CDC-2026-06-02-002'})
SET run.name = 'CDC demonstration run 2026-06-02',
    run.status = 'Rejected',
    run.mode = 'Continuous',
    run.batchNumber = 'AZDCDC10-260602',
    run.startTime = datetime('2026-06-02T08:00:00+01:00'),
    run.endTime = datetime('2026-06-02T11:40:00+01:00'),
    run.targetTabletCount = 250000,
    run.actualTabletCount = 0,
    run.yieldPct = 0.0,
    run.disposition = 'Rejected - material quarantined'
MERGE (run)-[:EXECUTES]->(recipe)
MERGE (run)-[:AT_SITE]->(site)
MERGE (run)-[:USES_LINE]->(line);

MATCH (run:ManufacturingRun {runId: 'RUN-CDC-2026-06-02-002'})
MATCH (op1:Operator {operatorId: 'OP-001'})
MATCH (op3:Operator {operatorId: 'OP-003'})
MATCH (clean:CleaningRecord {cleaningRecordId: 'CLEAN-CDC01-2026-05-31'})
MERGE (br:BatchRecord {batchRecordId: 'BR-AZDCDC10-260602'})
SET br.batchNumber = 'AZDCDC10-260602',
    br.recordType = 'Electronic batch record',
    br.status = 'Rejected',
    br.createdAt = datetime('2026-06-02T07:45:00+01:00'),
    br.reviewedAt = datetime('2026-06-02T16:30:00+01:00'),
    br.summary = 'Batch record documents persistent blend uniformity failure and quarantine of produced material.'
MERGE (run)-[:HAS_BATCH_RECORD]->(br)
MERGE (br)-[:SIGNED_BY {signatureMeaning: 'Performed by'}]->(op1)
MERGE (br)-[:SIGNED_BY {signatureMeaning: 'QA review'}]->(op3)
MERGE (br)-[:REFERENCES_CLEANING]->(clean);

MATCH (run:ManufacturingRun {runId: 'RUN-CDC-2026-06-02-002'})
UNWIND [
  {lotId: 'LOT-API-AZD-240501-A', quantityKg: 2.15, purpose: 'API input stream'},
  {lotId: 'LOT-MCC-260430-17', quantityKg: 26.20, purpose: 'MCC excipient stream'},
  {lotId: 'LOT-LACTOSE-260415-09', quantityKg: 10.42, purpose: 'Lactose excipient stream'},
  {lotId: 'LOT-CCS-260421-05', quantityKg: 2.08, purpose: 'Disintegrant excipient stream'},
  {lotId: 'LOT-MGST-260402-02', quantityKg: 0.84, purpose: 'Lubricant stream'}
] AS row
MATCH (lot:MaterialLot {lotId: row.lotId})
MERGE (run)-[r:CONSUMES]->(lot)
SET r.quantityKg = row.quantityKg,
    r.purpose = row.purpose,
    r.consumptionWindowStart = datetime('2026-06-02T08:05:00+01:00'),
    r.consumptionWindowEnd = datetime('2026-06-02T11:30:00+01:00');

MATCH (run:ManufacturingRun {runId: 'RUN-CDC-2026-06-02-002'})
UNWIND ['CAL-NIR-2026-05', 'CAL-CFS-2026-05', 'CAL-CHECK-2026-05', 'CAL-ENV-2026-05'] AS calId
MATCH (cal:CalibrationRecord {calibrationRecordId: calId})
MERGE (run)-[:USES_CALIBRATION]->(cal);

UNWIND [
  {id: 'READ2-API-FR-0815', sensorId: 'SENS-API-FEED-RATE', time: '2026-06-02T08:15:00+01:00', value: 1.20, unit: 'kg/h', target: 1.25, low: 1.19, high: 1.31, status: 'In specification'},
  {id: 'READ2-NIR-BU-0930', sensorId: 'SENS-NIR-BU', time: '2026-06-02T09:30:00+01:00', value: 6.4, unit: '%RSD', target: 3.0, low: 0.0, high: 5.0, status: 'Out of specification'},
  {id: 'READ2-NIR-BU-1000', sensorId: 'SENS-NIR-BU', time: '2026-06-02T10:00:00+01:00', value: 6.8, unit: '%RSD', target: 3.0, low: 0.0, high: 5.0, status: 'Out of specification'},
  {id: 'READ2-RH-0955', sensorId: 'SENS-ROOM-RH', time: '2026-06-02T09:55:00+01:00', value: 47.5, unit: '%RH', target: 35.0, low: 25.0, high: 45.0, status: 'Out of specification'}
] AS row
MATCH (sensor:Sensor {sensorId: row.sensorId})
MATCH (run:ManufacturingRun {runId: 'RUN-CDC-2026-06-02-002'})
MERGE (reading:SensorReading {readingId: row.id})
SET reading.timestamp = datetime(row.time),
    reading.value = row.value,
    reading.unit = row.unit,
    reading.targetValue = row.target,
    reading.lowerLimit = row.low,
    reading.upperLimit = row.high,
    reading.status = row.status,
    reading.sourceSystem = 'CDC historian demo'
MERGE (reading)-[:RECORDED_BY]->(sensor)
MERGE (reading)-[:DURING_RUN]->(run);

MATCH (reading:SensorReading)-[:RECORDED_BY]->(sensor:Sensor)-[:MEASURES]->(measure)
WHERE reading.readingId STARTS WITH 'READ2-'
MERGE (reading)-[:OBSERVES]->(measure);

MATCH (reading:SensorReading {readingId: 'READ2-NIR-BU-1000'})
MERGE (alarm:Alarm {alarmId: 'ALM-NIR-BU-20260602-002'})
SET alarm.name = 'Persistent blend uniformity failure alarm',
    alarm.alarmCode = 'NIR_BU_PERSISTENT_HIGH',
    alarm.severity = 'Critical',
    alarm.status = 'Closed',
    alarm.triggeredAt = datetime('2026-06-02T10:00:30+01:00'),
    alarm.limitValue = 5.0,
    alarm.operatorAction = 'Stopped line, quarantined produced material, and escalated to QA.'
MERGE (alarm)-[:TRIGGERED_BY]->(reading);

MATCH (run:ManufacturingRun {runId: 'RUN-CDC-2026-06-02-002'})
MATCH (alarm:Alarm {alarmId: 'ALM-NIR-BU-20260602-002'})
MATCH (rhReading:SensorReading {readingId: 'READ2-RH-0955'})
MATCH (qa:Operator {operatorId: 'OP-003'})
MERGE (dev:Deviation {deviationId: 'DEV-CDC-20260602-002'})
SET dev.title = 'Persistent blend uniformity failure during humidity excursion',
    dev.deviationType = 'Process excursion',
    dev.severity = 'Critical',
    dev.status = 'Closed',
    dev.openedAt = datetime('2026-06-02T10:10:00+01:00'),
    dev.closedAt = datetime('2026-06-02T16:00:00+01:00'),
    dev.rootCause = 'Persistent powder flow instability under humidity excursion; no acceptable recovery window established.',
    dev.impactAssessment = 'Produced material remained under quarantine and was not released for downstream use.',
    dev.capa = 'Line stopped, material rejected in demo disposition, and humidity response procedure flagged for revision.'
MERGE (run)-[:HAS_DEVIATION]->(dev)
MERGE (dev)-[:INVESTIGATES]->(alarm)
MERGE (dev)-[:CONSIDERS_READING]->(rhReading)
MERGE (dev)-[:APPROVED_BY]->(qa);

MATCH (br:BatchRecord {batchRecordId: 'BR-AZDCDC10-260602'})
MATCH (run:ManufacturingRun {runId: 'RUN-CDC-2026-06-02-002'})
MATCH (qa:Operator {operatorId: 'OP-003'})
MERGE (decision:QAReleaseDecision {decisionId: 'QA-REJ-AZDCDC10-260602'})
SET decision.decision = 'Reject',
    decision.status = 'Approved',
    decision.decidedAt = datetime('2026-06-02T17:00:00+01:00'),
    decision.rationale = 'Persistent blend uniformity failure; produced material quarantined and not released in demo data.'
MERGE (decision)-[:REVIEWS]->(br)
MERGE (decision)-[:REJECTS]->(run)
MERGE (decision)-[:DECIDED_BY]->(qa);
