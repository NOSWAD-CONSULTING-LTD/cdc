// Graph integrity validation checks for the CDC knowledge graph.
// These checks complement AI-readiness checks by validating structural graph
// assumptions used by architecture reviews, Neo4j Browser queries, and agents.

// 1. Product definition completeness.
MATCH (product:Product)
WITH product,
     EXISTS { (product)-[:HAS_FORMULATION]->(:Formulation) } AS hasFormulation,
     EXISTS { (product)-[:HAS_RECIPE]->(:Recipe) } AS hasRecipe,
     EXISTS { (product)-[:HAS_CMC_PACKAGE]->(:CMCPackage) } AS hasCmcPackage
RETURN 'Product definition completeness' AS checkName,
       count(product) AS total,
       sum(CASE WHEN hasFormulation AND hasRecipe AND hasCmcPackage THEN 1 ELSE 0 END) AS passing,
       collect(CASE WHEN NOT (hasFormulation AND hasRecipe AND hasCmcPackage) THEN product.productId END)[0..20] AS failingExamples;

// 2. Recipe step topology and ordering.
MATCH (recipe:Recipe)
OPTIONAL MATCH (recipe)-[:DEFINES_STEP]->(step:ProcessStep)
WITH recipe, collect(step) AS steps
OPTIONAL MATCH path = (:ProcessStep {stepId: 'STEP-001-API-FEED'})-[:NEXT_STEP*0..6]->(:ProcessStep {stepId: 'STEP-007-COLLECT'})
WITH recipe, steps, max(length(path)) AS pathLength
UNWIND steps AS step
WITH recipe, pathLength, count(step) AS stepCount, count(DISTINCT step.stepOrder) AS distinctStepOrders
WITH recipe,
     stepCount = 7 AND distinctStepOrders = 7 AND pathLength = 6 AS isValid,
     'steps=' + toString(stepCount) + ', distinctStepOrders=' + toString(distinctStepOrders) + ', pathLength=' + toString(pathLength) AS detail
RETURN 'Recipe step topology' AS checkName,
       count(recipe) AS total,
       sum(CASE WHEN isValid THEN 1 ELSE 0 END) AS passing,
       collect(CASE WHEN NOT isValid THEN recipe.recipeId + ' ' + detail END)[0..20] AS failingExamples;

// 3. End-to-end unit operation topology and ordering.
MATCH (operation:UnitOperation)
WITH count(operation) AS operationCount, count(DISTINCT operation.operationOrder) AS distinctOperationOrders
OPTIONAL MATCH path = (:UnitOperation {unitOperationId: 'UO-001-CRYSTALLISATION'})-[:NEXT_OPERATION*0..11]->(:UnitOperation {unitOperationId: 'UO-012-QA-CMC-REVIEW'})
WITH operationCount, distinctOperationOrders, max(length(path)) AS pathLength
WITH operationCount, distinctOperationOrders, pathLength,
     operationCount = 12 AND distinctOperationOrders = 12 AND pathLength = 11 AS isValid
RETURN 'End-to-end unit operation topology' AS checkName,
       1 AS total,
       CASE WHEN isValid THEN 1 ELSE 0 END AS passing,
       CASE WHEN isValid THEN [] ELSE ['operations=' + toString(operationCount) + ', distinctOrders=' + toString(distinctOperationOrders) + ', pathLength=' + toString(pathLength)] END AS failingExamples;

// 4. Manufacturing run execution context.
MATCH (run:ManufacturingRun)
WITH run,
     EXISTS { (run)-[:EXECUTES]->(:Recipe) } AS hasRecipe,
     EXISTS { (run)-[:AT_SITE]->(:ManufacturingSite) } AS hasSite,
     EXISTS { (run)-[:USES_LINE]->(:ManufacturingLine) } AS hasLine,
     EXISTS { (run)-[:HAS_BATCH_RECORD]->(:BatchRecord) } AS hasBatchRecord,
     EXISTS { (run)-[:CONSUMES]->(:MaterialLot) } AS hasConsumedLots,
     EXISTS { (:SensorReading)-[:DURING_RUN]->(run) } AS hasReadings
RETURN 'Manufacturing run execution context' AS checkName,
       count(run) AS total,
       sum(CASE WHEN hasRecipe AND hasSite AND hasLine AND hasBatchRecord AND hasConsumedLots AND hasReadings THEN 1 ELSE 0 END) AS passing,
       collect(CASE WHEN NOT (hasRecipe AND hasSite AND hasLine AND hasBatchRecord AND hasConsumedLots AND hasReadings) THEN run.runId END)[0..20] AS failingExamples;

// 5. Material lot genealogy completeness.
MATCH (lot:MaterialLot)
WITH lot,
     EXISTS { (lot)-[:INSTANCE_OF]->(:Material) } AS hasMaterial,
     EXISTS { (lot)-[:SUPPLIED_BY]->(:Supplier) } AS hasSupplier
RETURN 'Material lot genealogy completeness' AS checkName,
       count(lot) AS total,
       sum(CASE WHEN hasMaterial AND hasSupplier THEN 1 ELSE 0 END) AS passing,
       collect(CASE WHEN NOT (hasMaterial AND hasSupplier) THEN lot.lotId END)[0..20] AS failingExamples;

// 6. Sensor reading traceability.
MATCH (reading:SensorReading)
WITH reading,
     EXISTS { (reading)-[:RECORDED_BY]->(:Sensor) } AS hasSensor,
     EXISTS { (reading)-[:DURING_RUN]->(:ManufacturingRun) } AS hasRun,
     EXISTS { (reading)-[:OBSERVES]->() } AS hasObservedConcept
RETURN 'Sensor reading traceability' AS checkName,
       count(reading) AS total,
       sum(CASE WHEN hasSensor AND hasRun AND hasObservedConcept THEN 1 ELSE 0 END) AS passing,
       collect(CASE WHEN NOT (hasSensor AND hasRun AND hasObservedConcept) THEN reading.readingId END)[0..20] AS failingExamples;

// 7. Equipment and sensor asset context.
MATCH (equipment:Equipment)
WITH equipment,
     EXISTS { (equipment)-[:LOCATED_IN]->(:Room) } AS hasRoom,
     EXISTS { (:ManufacturingLine)-[:INCLUDES_EQUIPMENT]->(equipment) } AS hasLine
RETURN 'Equipment asset context' AS checkName,
       count(equipment) AS total,
       sum(CASE WHEN hasRoom AND hasLine THEN 1 ELSE 0 END) AS passing,
       collect(CASE WHEN NOT (hasRoom AND hasLine) THEN equipment.equipmentId END)[0..20] AS failingExamples;

// 8. QA disposition path completeness.
MATCH (decision:QAReleaseDecision)
OPTIONAL MATCH (decision)-[:REVIEWS]->(record:BatchRecord)<-[:HAS_BATCH_RECORD]-(reviewedRun:ManufacturingRun)
OPTIONAL MATCH (decision)-[disposition]->(disposedRun:ManufacturingRun)
WHERE type(disposition) IN ['RELEASES', 'REJECTS']
WITH decision, count(DISTINCT record) AS reviewedRecords, count(DISTINCT disposedRun) AS disposedRuns
WITH decision, reviewedRecords = 1 AND disposedRuns = 1 AS isValid
RETURN 'QA disposition path completeness' AS checkName,
       count(decision) AS total,
       sum(CASE WHEN isValid THEN 1 ELSE 0 END) AS passing,
       collect(CASE WHEN NOT isValid THEN decision.decisionId END)[0..20] AS failingExamples;

// 9. Standard mapping structural integrity.
MATCH (mapping:StandardMapping)
WITH mapping,
     EXISTS { (mapping)-[:MAPS_CDE]->(:CriticalDataElement) } AS hasCde,
     EXISTS { (mapping)-[:TO_STANDARD]->(:DataStandard) } AS hasStandard
RETURN 'Standard mapping structural integrity' AS checkName,
       count(mapping) AS total,
       sum(CASE WHEN hasCde AND hasStandard THEN 1 ELSE 0 END) AS passing,
       collect(CASE WHEN NOT (hasCde AND hasStandard) THEN mapping.mappingId END)[0..20] AS failingExamples;

// 10. CDE definition governance versioning.
MATCH (cde:CriticalDataElement)
WITH cde,
     EXISTS { (cde)-[:HAS_VERSION]->(:CDEVersion) } AS hasVersion,
     EXISTS { (cde)-[:HAS_VERSION]->(:CDEVersion)-[:APPROVED_BY]->(:CDEDefinitionApproval) } AS hasApproval
RETURN 'CDE definition versioning integrity' AS checkName,
       count(cde) AS total,
       sum(CASE WHEN hasVersion AND hasApproval THEN 1 ELSE 0 END) AS passing,
       collect(CASE WHEN NOT (hasVersion AND hasApproval) THEN cde.cdeId END)[0..20] AS failingExamples;

// 11. Approved agent template relationship availability.
CALL db.relationshipTypes() YIELD relationshipType
WITH collect(relationshipType) AS availableTypes
WITH availableTypes,
     [
       'CONSUMES',
       'INSTANCE_OF',
       'SUPPLIED_BY',
       'HAS_DEVIATION',
       'INVESTIGATES',
       'TRIGGERED_BY',
       'RECORDED_BY',
       'CONSIDERS_READING',
       'SUPPORTS_CMC_SECTION',
       'OBSERVED_AT',
       'MAPS_TO_STANDARD',
       'HAS_VALUE_DOMAIN',
       'VALUE_OF',
       'CONFORMS_TO_VALUE_DOMAIN',
       'OBSERVED_DURING',
       'DERIVED_FROM_READING',
       'RELEASES',
       'REJECTS',
       'DEFINES_STEP',
       'USES_EQUIPMENT',
       'HAS_SENSOR',
       'COVERS',
       'SUBMITS',
       'SUPPORTS',
       'NEXT_OPERATION',
       'EVIDENCES_CDE_VALUE',
       'SUPPORTS_MAPPING',
       'HAS_CDE_DOMAIN',
       'HAS_CRITICALITY_LEVEL',
       'HAS_DECISION_STATUS',
       'HAS_RUN_STATUS',
       'REFERENCES_RELATIONSHIP_DEFINITION'
     ] AS requiredTypes
WITH requiredTypes, [relType IN requiredTypes WHERE NOT relType IN availableTypes] AS missingTypes
RETURN 'Approved agent template relationship availability' AS checkName,
       size(requiredTypes) AS total,
       size(requiredTypes) - size(missingTypes) AS passing,
       missingTypes AS failingExamples;

// 12. Evidence document structural integrity.
MATCH (doc:EvidenceDocument)
WITH doc,
     doc.title IS NOT NULL AS hasTitle,
     doc.documentType IS NOT NULL AS hasType,
     EXISTS { (doc)--() } AS hasEvidenceLink
RETURN 'Evidence document structural integrity' AS checkName,
       count(doc) AS total,
       sum(CASE WHEN hasTitle AND hasType AND hasEvidenceLink THEN 1 ELSE 0 END) AS passing,
       collect(CASE WHEN NOT (hasTitle AND hasType AND hasEvidenceLink) THEN doc.documentId END)[0..20] AS failingExamples;

// 13. Controlled vocabulary structural integrity.
CALL {
  MATCH (domain:CDEDomain)
  RETURN domain.domainId AS id, EXISTS { (:CriticalDataElement)-[:HAS_CDE_DOMAIN]->(domain) } AS isUsed
  UNION ALL
  MATCH (criticality:CriticalityLevel)
  RETURN criticality.criticalityId AS id, EXISTS { (:CriticalDataElement)-[:HAS_CRITICALITY_LEVEL]->(criticality) } AS isUsed
  UNION ALL
  MATCH (status:RunStatus)
  RETURN status.runStatusId AS id, EXISTS { (:ManufacturingRun)-[:HAS_RUN_STATUS]->(status) } AS isUsed
  UNION ALL
  MATCH (status:DecisionStatus)
  RETURN status.decisionStatusId AS id, EXISTS { (:QAReleaseDecision)-[:HAS_DECISION_STATUS]->(status) } AS isUsed
  UNION ALL
  MATCH (severity:DeviationSeverity)
  RETURN severity.severityId AS id, EXISTS { (:Deviation)-[:HAS_DEVIATION_SEVERITY]->(severity) } AS isUsed
}
RETURN 'Controlled vocabulary structural integrity' AS checkName,
       count(id) AS total,
       sum(CASE WHEN isUsed THEN 1 ELSE 0 END) AS passing,
       collect(CASE WHEN NOT isUsed THEN id END)[0..20] AS failingExamples;

// 14. Relationship definition structural integrity.
MATCH (rel:RelationshipDefinition)
WITH rel,
     rel.neo4jType IS NOT NULL AS hasNeo4jType,
     rel.ontologyPredicate IS NOT NULL AS hasPredicate,
     rel.subjectLabel IS NOT NULL AS hasSubject,
     rel.objectLabel IS NOT NULL AS hasObject,
     EXISTS { (:CMCPackage)-[:REFERENCES_RELATIONSHIP_DEFINITION]->(rel) } AS isAnchored
RETURN 'Relationship definition structural integrity' AS checkName,
       count(rel) AS total,
       sum(CASE WHEN hasNeo4jType AND hasPredicate AND hasSubject AND hasObject AND isAnchored THEN 1 ELSE 0 END) AS passing,
       collect(CASE WHEN NOT (hasNeo4jType AND hasPredicate AND hasSubject AND hasObject AND isAnchored) THEN rel.relationshipDefinitionId END)[0..20] AS failingExamples;

// 15. Orphan node hygiene.
OPTIONAL MATCH (n)
WHERE NOT (n)--()
RETURN 'Orphan node hygiene' AS checkName,
       1 AS total,
       CASE WHEN count(n) = 0 THEN 1 ELSE 0 END AS passing,
       CASE WHEN count(n) = 0 THEN [] ELSE collect(coalesce(n.productId, n.runId, n.cdeId, n.name, elementId(n)))[0..20] END AS failingExamples;
