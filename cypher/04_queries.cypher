// Example CDC knowledge graph queries.
// Replace IDs in WHERE clauses to explore other products, runs, lots, CQAs, or filings.

// 1. Show the full CDC process graph for one manufacturing run.
MATCH path =
  (run:ManufacturingRun {runId: 'RUN-CDC-2026-06-01-001'})-
  [:EXECUTES|AT_SITE|USES_LINE|CONSUMES|HAS_BATCH_RECORD|HAS_DEVIATION|USES_CALIBRATION*1..3]-
  (n)
RETURN path;

// 2. Trace finished product back to consumed material lots and suppliers.
MATCH (product:Product {productId: 'PROD-AZD-CDC-TAB-10MG'})-[:HAS_RECIPE]->(:Recipe)<-[:EXECUTES]-(run:ManufacturingRun)
MATCH (run)-[consumes:CONSUMES]->(lot:MaterialLot)-[:INSTANCE_OF]->(material:Material)
MATCH (lot)-[:SUPPLIED_BY]->(supplier:Supplier)
RETURN product.name AS product,
       run.batchNumber AS batchNumber,
       lot.lotNumber AS materialLot,
       material.name AS material,
       material.materialRole AS role,
       consumes.quantityKg AS quantityKg,
       supplier.name AS supplier,
       supplier.qualificationStatus AS supplierStatus
ORDER BY role, materialLot;

// 3. Find all CPPs that impact a selected CQA.
MATCH (cpp:CPP)-[impact:IMPACTS]->(cqa:CQA {cqaId: 'CQA-BLEND-UNIFORMITY'})
OPTIONAL MATCH (cpp)-[:CONTROLS]->(step:ProcessStep)
RETURN cqa.name AS cqa,
       cpp.name AS cpp,
       cpp.targetValue AS target,
       cpp.lowerLimit AS lowerLimit,
       cpp.upperLimit AS upperLimit,
       cpp.unit AS unit,
       step.stepOrder AS stepOrder,
       step.name AS processStep,
       impact.rationale AS rationale
ORDER BY stepOrder, cpp.name;

// 4. Find all sensor readings outside specification.
MATCH (reading:SensorReading)
WHERE reading.status = 'Out of specification'
   OR reading.value < reading.lowerLimit
   OR reading.value > reading.upperLimit
MATCH (reading)-[:RECORDED_BY]->(sensor:Sensor)
MATCH (reading)-[:DURING_RUN]->(run:ManufacturingRun)
OPTIONAL MATCH (reading)-[:OBSERVES]->(measure)
RETURN run.runId AS runId,
       run.batchNumber AS batchNumber,
       reading.timestamp AS timestamp,
       sensor.name AS sensor,
       labels(measure)[0] AS measuredType,
       measure.name AS measuredParameter,
       reading.value AS value,
       reading.unit AS unit,
       reading.lowerLimit AS lowerLimit,
       reading.upperLimit AS upperLimit,
       reading.status AS status
ORDER BY timestamp;

// 5. Show deviations and the alarms/readings that caused them.
MATCH (run:ManufacturingRun)-[:HAS_DEVIATION]->(dev:Deviation)-[:INVESTIGATES]->(alarm:Alarm)-[:TRIGGERED_BY]->(reading:SensorReading)
MATCH (reading)-[:RECORDED_BY]->(sensor:Sensor)
OPTIONAL MATCH (dev)-[:CONSIDERS_READING]->(supportingReading:SensorReading)-[:RECORDED_BY]->(supportingSensor:Sensor)
RETURN run.batchNumber AS batchNumber,
       dev.deviationId AS deviationId,
       dev.title AS title,
       dev.severity AS severity,
       dev.status AS deviationStatus,
       alarm.alarmCode AS alarmCode,
       alarm.severity AS alarmSeverity,
       reading.timestamp AS triggeringTime,
       sensor.name AS triggeringSensor,
       reading.value AS triggeringValue,
       reading.unit AS unit,
       collect(DISTINCT supportingSensor.name + ' = ' + toString(supportingReading.value) + ' ' + supportingReading.unit) AS supportingReadings,
       dev.impactAssessment AS impactAssessment;

// 6. Show which equipment and sensors were involved in a released run.
MATCH (decision:QAReleaseDecision)-[:RELEASES]->(run:ManufacturingRun {runId: 'RUN-CDC-2026-06-01-001'})
MATCH (run)-[:EXECUTES]->(:Recipe)-[defines:DEFINES_STEP]->(step:ProcessStep)-[:USES_EQUIPMENT]->(equipment:Equipment)
OPTIONAL MATCH (equipment)-[:HAS_SENSOR]->(sensor:Sensor)
RETURN run.batchNumber AS batchNumber,
       decision.decision AS qaDecision,
       step.stepOrder AS stepOrder,
       step.name AS processStep,
       equipment.name AS equipment,
       equipment.equipmentType AS equipmentType,
       collect(DISTINCT sensor.name) AS sensors
ORDER BY stepOrder, equipment;

// 7. Show regulatory filing evidence connected to the product.
MATCH (filing:RegulatoryFiling)-[:COVERS]->(product:Product {productId: 'PROD-AZD-CDC-TAB-10MG'})
OPTIONAL MATCH (evidence:ValidationEvidence)-[:SUPPORTS]->(filing)
RETURN product.name AS product,
       filing.name AS filing,
       filing.region AS region,
       filing.status AS filingStatus,
       collect(DISTINCT {
         evidenceId: evidence.evidenceId,
         name: evidence.name,
         type: evidence.evidenceType,
         status: evidence.status,
         summary: evidence.summary
       }) AS evidence;

// 8. Show process step order from recipe to finished tablet.
MATCH (recipe:Recipe {recipeId: 'REC-AZD-CDC-DC-001'})-[defines:DEFINES_STEP]->(step:ProcessStep)
OPTIONAL MATCH (step)-[:USES_EQUIPMENT]->(equipment:Equipment)
RETURN recipe.name AS recipe,
       defines.stepOrder AS stepOrder,
       step.name AS processStep,
       step.description AS description,
       collect(DISTINCT equipment.name) AS equipment
ORDER BY stepOrder;

// Alternative path form for Neo4j Browser visual step sequence.
MATCH path = (:ProcessStep {stepId: 'STEP-001-API-FEED'})-[:NEXT_STEP*0..6]->(:ProcessStep {stepId: 'STEP-007-COLLECT'})
RETURN path;

// 9. Identify all runs affected by a specific material lot.
MATCH (lot:MaterialLot {lotId: 'LOT-API-AZD-240501-A'})<-[:CONSUMES]-(run:ManufacturingRun)
OPTIONAL MATCH (run)-[:HAS_DEVIATION]->(dev:Deviation)
OPTIONAL MATCH (decision:QAReleaseDecision)-[:RELEASES]->(run)
RETURN lot.lotNumber AS lotNumber,
       run.runId AS runId,
       run.batchNumber AS batchNumber,
       run.status AS runStatus,
       run.startTime AS startTime,
       collect(DISTINCT dev.deviationId) AS deviations,
       collect(DISTINCT decision.decision) AS qaDecisions
ORDER BY startTime;

// 10. Graph-friendly Neo4j Browser query for one run.
// Returns a bounded but rich neighborhood: recipe, steps, equipment, sensors,
// readings, alarms, deviations, material lots, suppliers, batch record, QA, and evidence.
MATCH (run:ManufacturingRun {runId: 'RUN-CDC-2026-06-01-001'})
OPTIONAL MATCH processPath = (run)-[:EXECUTES]->(:Recipe)-[:DEFINES_STEP]->(:ProcessStep)-[:USES_EQUIPMENT]->(:Equipment)-[:HAS_SENSOR]->(:Sensor)
OPTIONAL MATCH readingPath = (run)<-[:DURING_RUN]-(:SensorReading)-[:RECORDED_BY]->(:Sensor)
OPTIONAL MATCH genealogyPath = (run)-[:CONSUMES]->(:MaterialLot)-[:INSTANCE_OF|SUPPLIED_BY]->()
OPTIONAL MATCH qualityPath = (run)-[:HAS_DEVIATION]->(:Deviation)-[:INVESTIGATES]->(:Alarm)-[:TRIGGERED_BY]->(:SensorReading)
OPTIONAL MATCH batchPath = (run)-[:HAS_BATCH_RECORD]->(:BatchRecord)<-[:REVIEWS]-(:QAReleaseDecision)-[:RELEASES]->(run)
RETURN processPath, readingPath, genealogyPath, qualityPath, batchPath;
