// End-to-end CDC conceptual model and CDE registry queries.

// 1. Show the process from crystallisation to powder coated tablet review.
MATCH path = (:UnitOperation {unitOperationId: 'UO-001-CRYSTALLISATION'})-[:NEXT_OPERATION*0..11]->(:UnitOperation {unitOperationId: 'UO-012-QA-CMC-REVIEW'})
RETURN path;

// 2. List CDEs by unit operation in process order.
MATCH (cde:CriticalDataElement)-[:OBSERVED_AT]->(uo:UnitOperation)
OPTIONAL MATCH (cde)-[:SOURCED_FROM]->(source:DataSourceSystem)
OPTIONAL MATCH (cde)-[:HAS_OWNER]->(owner:DataOwner)
OPTIONAL MATCH (cde)-[:HAS_STEWARD]->(steward:DataSteward)
RETURN uo.operationOrder AS operationOrder,
       uo.name AS unitOperation,
       cde.cdeId AS cdeId,
       cde.name AS cde,
       cde.domain AS domain,
       cde.criticality AS criticality,
       source.name AS sourceSystem,
       owner.name AS dataOwner,
       steward.name AS dataSteward
ORDER BY operationOrder, cde.name;

// 3. Trace one CDE to standards, CMC sections, source, owner, steward, and data quality rules.
MATCH (cde:CriticalDataElement {cdeId: 'CDE-CDC-BLEND-NIR'})
OPTIONAL MATCH (cde)-[:OBSERVED_AT]->(uo:UnitOperation)
OPTIONAL MATCH (cde)-[:SOURCED_FROM]->(source:DataSourceSystem)
OPTIONAL MATCH (cde)-[:HAS_OWNER]->(owner:DataOwner)
OPTIONAL MATCH (cde)-[:HAS_STEWARD]->(steward:DataSteward)
OPTIONAL MATCH (cde)-[:HAS_DATA_QUALITY_RULE]->(rule:DataQualityRule)
OPTIONAL MATCH (cde)-[:MAPS_TO_STANDARD]->(standard:DataStandard)
OPTIONAL MATCH (cde)-[:SUPPORTS_CMC_SECTION]->(section:RegulatorySection)
OPTIONAL MATCH (cde)-[:DESCRIBES]->(concept)
RETURN cde.cdeId AS cdeId,
       cde.name AS cde,
       cde.domain AS domain,
       cde.criticality AS criticality,
       collect(DISTINCT uo.name) AS observedAt,
       collect(DISTINCT labels(concept)[0] + ': ' + coalesce(concept.name, concept.cqaId, concept.cppId, concept.decisionId)) AS describes,
       collect(DISTINCT source.name) AS sourceSystems,
       collect(DISTINCT owner.name) AS owners,
       collect(DISTINCT steward.name) AS stewards,
       collect(DISTINCT rule.name) AS dataQualityRules,
       collect(DISTINCT standard.name) AS standards,
       collect(DISTINCT section.name) AS cmcSections;

// 4. Find CDEs supporting a selected CTD Module 3 section.
MATCH (section:RegulatorySection {sectionId: 'CTD-3.2.P.3.4'})<-[:SUPPORTS_CMC_SECTION]-(cde:CriticalDataElement)-[:OBSERVED_AT]->(uo:UnitOperation)
OPTIONAL MATCH (cde)-[:MAPS_TO_STANDARD]->(standard:DataStandard)
RETURN section.name AS cmcSection,
       uo.operationOrder AS operationOrder,
       uo.name AS unitOperation,
       cde.name AS cde,
       cde.domain AS domain,
       cde.criticality AS criticality,
       collect(DISTINCT standard.name) AS standards
ORDER BY operationOrder, cde.name;

// 5. Show CDEs by source system and ISA-95 layer.
MATCH (cde:CriticalDataElement)-[:SOURCED_FROM]->(source:DataSourceSystem)
RETURN source.isa95Level AS isa95Level,
       source.name AS sourceSystem,
       source.systemType AS systemType,
       count(cde) AS cdeCount,
       collect(cde.name) AS cdes
ORDER BY isa95Level, sourceSystem;

// 6. Show data quality rules required for critical CDEs.
MATCH (cde:CriticalDataElement {criticality: 'Critical'})-[:HAS_DATA_QUALITY_RULE]->(rule:DataQualityRule)
RETURN rule.dimension AS dataQualityDimension,
       rule.name AS rule,
       count(cde) AS criticalCdeCount,
       collect(cde.name) AS cdes
ORDER BY dataQualityDimension, rule;

// 7. Show CDEs governed by the CMC package and used by the control strategy.
MATCH (cmc:CMCPackage {cmcPackageId: 'CMC-NCL-CDC-10MG-001'})-[:GOVERNS_CDE]->(cde:CriticalDataElement)
OPTIONAL MATCH (:ControlStrategy {controlStrategyId: 'CS-NCL-CDC-10MG-001'})-[:USES_CDE]->(cde)
WITH cmc, cde, count(*) > 0 AS usedByControlStrategy
RETURN cmc.name AS cmcPackage,
       cde.domain AS domain,
       cde.criticality AS criticality,
       usedByControlStrategy,
       count(cde) AS cdeCount,
       collect(cde.name) AS cdes
ORDER BY domain, criticality;

// 8. Show standard mappings for all CDEs.
MATCH (mapping:StandardMapping)-[:MAPS_CDE]->(cde:CriticalDataElement)
MATCH (mapping)-[:TO_STANDARD]->(standard:DataStandard)
OPTIONAL MATCH (mapping)-[:TO_REGULATORY_SECTION]->(section:RegulatorySection)
RETURN cde.name AS cde,
       standard.name AS standard,
       standard.standardType AS standardType,
       collect(DISTINCT section.sectionId + ' ' + section.name) AS regulatorySections,
       mapping.rationale AS rationale
ORDER BY cde, standard;

// 9. Show material transformation and intermediate products.
MATCH (uo:UnitOperation)
OPTIONAL MATCH (uo)-[:HAS_TRANSFORMATION]->(transformation:MaterialTransformation)
OPTIONAL MATCH (uo)-[:PRODUCES]->(intermediate:IntermediateProduct)
RETURN uo.operationOrder AS operationOrder,
       uo.name AS unitOperation,
       collect(DISTINCT transformation.fromState + ' -> ' + transformation.toState) AS transformations,
       collect(DISTINCT intermediate.name + ' (' + intermediate.materialState + ')') AS intermediateProducts
ORDER BY operationOrder;

// 10. Graph-friendly end-to-end CDE model visualisation.
MATCH (cmc:CMCPackage {cmcPackageId: 'CMC-NCL-CDC-10MG-001'})
OPTIONAL MATCH operationPath = (:UnitOperation {unitOperationId: 'UO-001-CRYSTALLISATION'})-[:NEXT_OPERATION*0..11]->(:UnitOperation {unitOperationId: 'UO-012-QA-CMC-REVIEW'})
OPTIONAL MATCH cdePath = (cmc)-[:GOVERNS_CDE]->(:CriticalDataElement)-[:OBSERVED_AT]->(:UnitOperation)
OPTIONAL MATCH standardPath = (:CriticalDataElement)-[:MAPS_TO_STANDARD]->(:DataStandard)
OPTIONAL MATCH cmcPath = (:CriticalDataElement)-[:SUPPORTS_CMC_SECTION]->(:RegulatorySection)
RETURN operationPath, cdePath, standardPath, cmcPath;
