// AI-readiness validation checks for the CDC knowledge graph.
// These queries are intentionally tabular so they can be used in CI or copied
// into Neo4j Browser during architecture review.

// 1. CDE governance completeness.
MATCH (cde:CriticalDataElement)
WITH cde,
     EXISTS { (cde)-[:OBSERVED_AT]->(:UnitOperation) } AS hasOperation,
     EXISTS { (cde)-[:SOURCED_FROM]->(:DataSourceSystem) } AS hasSource,
     EXISTS { (cde)-[:HAS_OWNER]->(:DataOwner) } AS hasOwner,
     EXISTS { (cde)-[:HAS_STEWARD]->(:DataSteward) } AS hasSteward,
     EXISTS { (cde)-[:HAS_DATA_QUALITY_RULE]->(:DataQualityRule) } AS hasRule,
     EXISTS { (cde)-[:MAPS_TO_STANDARD]->(:DataStandard) } AS hasStandard,
     EXISTS { (cde)-[:SUPPORTS_CMC_SECTION]->(:RegulatorySection) } AS hasCmcSection
RETURN 'CDE governance completeness' AS checkName,
       count(cde) AS total,
       sum(CASE WHEN hasOperation AND hasSource AND hasOwner AND hasSteward AND hasRule AND hasStandard AND hasCmcSection THEN 1 ELSE 0 END) AS passing,
       collect(CASE WHEN NOT (hasOperation AND hasSource AND hasOwner AND hasSteward AND hasRule AND hasStandard AND hasCmcSection) THEN cde.cdeId END)[0..20] AS failingExamples;

// 2. CDE semantic grounding.
MATCH (cde:CriticalDataElement)
WITH cde, EXISTS { (cde)-[:DESCRIBES]->() } AS hasGrounding
RETURN 'CDE semantic grounding' AS checkName,
       count(cde) AS total,
       sum(CASE WHEN hasGrounding THEN 1 ELSE 0 END) AS passing,
       collect(CASE WHEN NOT hasGrounding THEN cde.cdeId END)[0..20] AS failingExamples;

// 3. CDE value-domain and representative value coverage.
MATCH (cde:CriticalDataElement)
WITH cde,
     EXISTS { (cde)-[:HAS_VALUE_DOMAIN]->(:ValueDomain) } AS hasValueDomain,
     EXISTS { (:CDEValue)-[:VALUE_OF]->(cde) } AS hasRepresentativeValue
RETURN 'CDE value metadata coverage' AS checkName,
       count(cde) AS total,
       sum(CASE WHEN hasValueDomain AND hasRepresentativeValue THEN 1 ELSE 0 END) AS passing,
       collect(CASE WHEN NOT (hasValueDomain AND hasRepresentativeValue) THEN cde.cdeId END)[0..20] AS failingExamples;

// 4. Standard mapping provenance.
MATCH (mapping:StandardMapping)
WITH mapping, EXISTS { (mapping)-[:SUPPORTED_BY_PROVENANCE]->(:ProvenanceStatement) } AS hasProvenance
RETURN 'Standard mapping provenance' AS checkName,
       count(mapping) AS total,
       sum(CASE WHEN hasProvenance THEN 1 ELSE 0 END) AS passing,
       collect(CASE WHEN NOT hasProvenance THEN mapping.mappingId END)[0..20] AS failingExamples;

// 5. CDE values are linked to value domains and run evidence.
MATCH (value:CDEValue)
WITH value,
     EXISTS { (value)-[:VALUE_OF]->(:CriticalDataElement) } AS hasCde,
     EXISTS { (value)-[:CONFORMS_TO_VALUE_DOMAIN]->(:ValueDomain) } AS hasDomain,
     EXISTS { (value)-[:OBSERVED_DURING]->(:ManufacturingRun) } AS hasRun
RETURN 'CDE value evidence coverage' AS checkName,
       count(value) AS total,
       sum(CASE WHEN hasCde AND hasDomain AND hasRun THEN 1 ELSE 0 END) AS passing,
       collect(CASE WHEN NOT (hasCde AND hasDomain AND hasRun) THEN value.cdeValueId END)[0..20] AS failingExamples;

// 6. Source systems have ISA-95 context.
MATCH (source:DataSourceSystem)
WITH source, source.isa95Level IS NOT NULL AS hasIsa95Level
RETURN 'Source system ISA-95 coverage' AS checkName,
       count(source) AS total,
       sum(CASE WHEN hasIsa95Level THEN 1 ELSE 0 END) AS passing,
       collect(CASE WHEN NOT hasIsa95Level THEN source.sourceSystemId END)[0..20] AS failingExamples;

// 7. End-to-end unit operation path is connected.
MATCH path = (:UnitOperation {unitOperationId: 'UO-001-CRYSTALLISATION'})-[:NEXT_OPERATION*0..11]->(:UnitOperation {unitOperationId: 'UO-012-QA-CMC-REVIEW'})
RETURN 'End-to-end operation path' AS checkName,
       1 AS total,
       CASE WHEN length(path) = 11 THEN 1 ELSE 0 END AS passing,
       CASE WHEN length(path) = 11 THEN [] ELSE ['Expected path length 11, got ' + toString(length(path))] END AS failingExamples
LIMIT 1;

// 8. Demo graph hygiene.
MATCH (n)
WHERE labels(n) = []
RETURN 'Unlabeled node hygiene' AS checkName,
       1 AS total,
       CASE WHEN count(n) = 0 THEN 1 ELSE 0 END AS passing,
       CASE WHEN count(n) = 0 THEN [] ELSE ['Unlabeled node count: ' + toString(count(n))] END AS failingExamples;

// 9. Evidence documents are connected to graph evidence.
MATCH (doc:EvidenceDocument)
WITH doc, EXISTS { (doc)--() } AS hasGraphLink
RETURN 'Evidence document linkage' AS checkName,
       count(doc) AS total,
       sum(CASE WHEN hasGraphLink THEN 1 ELSE 0 END) AS passing,
       collect(CASE WHEN NOT hasGraphLink THEN doc.documentId END)[0..20] AS failingExamples;

// 10. CDEs are connected to controlled vocabulary nodes.
MATCH (cde:CriticalDataElement)
WITH cde,
     EXISTS { (cde)-[:HAS_CDE_DOMAIN]->(:CDEDomain) } AS hasDomainVocabulary,
     EXISTS { (cde)-[:HAS_CRITICALITY_LEVEL]->(:CriticalityLevel) } AS hasCriticalityVocabulary
RETURN 'CDE controlled vocabulary coverage' AS checkName,
       count(cde) AS total,
       sum(CASE WHEN hasDomainVocabulary AND hasCriticalityVocabulary THEN 1 ELSE 0 END) AS passing,
       collect(CASE WHEN NOT (hasDomainVocabulary AND hasCriticalityVocabulary) THEN cde.cdeId END)[0..20] AS failingExamples;

// 11. Relationship definitions are anchored for semantic lookup.
MATCH (rel:RelationshipDefinition)
WITH rel,
     rel.neo4jType IS NOT NULL AS hasNeo4jType,
     rel.ontologyPredicate IS NOT NULL AS hasPredicate,
     EXISTS { (:CMCPackage)-[:REFERENCES_RELATIONSHIP_DEFINITION]->(rel) } AS isAnchored
RETURN 'Relationship definition coverage' AS checkName,
       count(rel) AS total,
       sum(CASE WHEN hasNeo4jType AND hasPredicate AND isAnchored THEN 1 ELSE 0 END) AS passing,
       collect(CASE WHEN NOT (hasNeo4jType AND hasPredicate AND isAnchored) THEN rel.relationshipDefinitionId END)[0..20] AS failingExamples;
