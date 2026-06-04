// AI-readiness enrichment for the CDC CDE graph.
// Adds value domains, units, CDE versions/approvals, representative CDE values,
// provenance, and additional grounding links so CDEs are easier to retrieve and explain.

// ---------------------------------------------------------------------------
// Units of measure and value domains
// ---------------------------------------------------------------------------
UNWIND [
  {id: 'UOM-NONE', symbol: '1', name: 'Dimensionless or identifier', quantityKind: 'Identifier or dimensionless'},
  {id: 'UOM-PERCENT', symbol: '%', name: 'Percent', quantityKind: 'Ratio'},
  {id: 'UOM-PERCENT-WW', symbol: '% w/w', name: 'Percent weight by weight', quantityKind: 'Composition'},
  {id: 'UOM-DEGC', symbol: 'degC', name: 'Degree Celsius', quantityKind: 'Temperature'},
  {id: 'UOM-RPM', symbol: 'rpm', name: 'Revolutions per minute', quantityKind: 'Rotational speed'},
  {id: 'UOM-KG-H', symbol: 'kg/h', name: 'Kilogram per hour', quantityKind: 'Mass flow'},
  {id: 'UOM-KG', symbol: 'kg', name: 'Kilogram', quantityKind: 'Mass'},
  {id: 'UOM-MG', symbol: 'mg', name: 'Milligram', quantityKind: 'Mass'},
  {id: 'UOM-SECONDS', symbol: 's', name: 'Second', quantityKind: 'Time'},
  {id: 'UOM-HOURS', symbol: 'h', name: 'Hour', quantityKind: 'Time'},
  {id: 'UOM-UM', symbol: 'um', name: 'Micrometre', quantityKind: 'Length'},
  {id: 'UOM-KN', symbol: 'kN', name: 'Kilonewton', quantityKind: 'Force'},
  {id: 'UOM-RH', symbol: '%RH', name: 'Percent relative humidity', quantityKind: 'Relative humidity'},
  {id: 'UOM-VOLT', symbol: 'V', name: 'Volt', quantityKind: 'Electrical potential'},
  {id: 'UOM-ML', symbol: 'mL', name: 'Millilitre', quantityKind: 'Volume'}
] AS row
MERGE (unit:UnitOfMeasure {unitId: row.id})
SET unit.symbol = row.symbol,
    unit.name = row.name,
    unit.quantityKind = row.quantityKind;

UNWIND [
  {id: 'VD-IDENTIFIER', name: 'Identifier value domain', dataType: 'string', unitId: 'UOM-NONE', description: 'Controlled identifier for lots, containers, records, or sections.'},
  {id: 'VD-NUMERIC-PERCENT', name: 'Numeric percent value domain', dataType: 'decimal', unitId: 'UOM-PERCENT', description: 'Numeric percentage value.'},
  {id: 'VD-NUMERIC-PERCENT-WW', name: 'Numeric percent w/w value domain', dataType: 'decimal', unitId: 'UOM-PERCENT-WW', description: 'Numeric composition value in percent w/w.'},
  {id: 'VD-TEMPERATURE', name: 'Temperature value domain', dataType: 'decimal', unitId: 'UOM-DEGC', description: 'Temperature in degrees Celsius.'},
  {id: 'VD-SPEED', name: 'Rotational speed value domain', dataType: 'decimal', unitId: 'UOM-RPM', description: 'Rotational speed in rpm.'},
  {id: 'VD-MASS-FLOW', name: 'Mass flow value domain', dataType: 'decimal', unitId: 'UOM-KG-H', description: 'Mass flow in kg/h.'},
  {id: 'VD-MASS-KG', name: 'Mass value domain', dataType: 'decimal', unitId: 'UOM-KG', description: 'Mass in kg.'},
  {id: 'VD-MASS-MG', name: 'Tablet mass value domain', dataType: 'decimal', unitId: 'UOM-MG', description: 'Tablet mass in mg.'},
  {id: 'VD-TIME-SECONDS', name: 'Seconds value domain', dataType: 'decimal', unitId: 'UOM-SECONDS', description: 'Duration in seconds.'},
  {id: 'VD-TIME-HOURS', name: 'Hours value domain', dataType: 'decimal', unitId: 'UOM-HOURS', description: 'Duration in hours.'},
  {id: 'VD-PARTICLE-SIZE', name: 'Particle size value domain', dataType: 'decimal', unitId: 'UOM-UM', description: 'Particle or crystal size in micrometres.'},
  {id: 'VD-FORCE', name: 'Force value domain', dataType: 'decimal', unitId: 'UOM-KN', description: 'Compression force in kN.'},
  {id: 'VD-RH', name: 'Relative humidity value domain', dataType: 'decimal', unitId: 'UOM-RH', description: 'Relative humidity percentage.'},
  {id: 'VD-DISPOSITION', name: 'QA disposition value domain', dataType: 'controlled string', unitId: 'UOM-NONE', description: 'Controlled QA disposition decision.'},
  {id: 'VD-REGULATORY-SECTION', name: 'Regulatory section value domain', dataType: 'controlled string', unitId: 'UOM-NONE', description: 'Controlled CTD Module 3 section identifier.'}
] AS row
MATCH (unit:UnitOfMeasure {unitId: row.unitId})
MERGE (vd:ValueDomain {valueDomainId: row.id})
SET vd.name = row.name,
    vd.dataType = row.dataType,
    vd.description = row.description,
    vd.status = 'Reference value domain'
MERGE (vd)-[:USES_UNIT]->(unit);

UNWIND [
  {id: 'AV-DISP-RELEASE', value: 'Release', domainId: 'VD-DISPOSITION'},
  {id: 'AV-DISP-REJECT', value: 'Reject', domainId: 'VD-DISPOSITION'},
  {id: 'AV-DISP-QUARANTINE', value: 'Quarantine', domainId: 'VD-DISPOSITION'},
  {id: 'AV-CTD-3.2.S.2.2', value: 'CTD-3.2.S.2.2', domainId: 'VD-REGULATORY-SECTION'},
  {id: 'AV-CTD-3.2.P.3.4', value: 'CTD-3.2.P.3.4', domainId: 'VD-REGULATORY-SECTION'},
  {id: 'AV-CTD-3.2.P.5', value: 'CTD-3.2.P.5', domainId: 'VD-REGULATORY-SECTION'}
] AS row
MATCH (vd:ValueDomain {valueDomainId: row.domainId})
MERGE (av:AllowedValue {allowedValueId: row.id})
SET av.value = row.value,
    av.status = 'Allowed'
MERGE (vd)-[:HAS_ALLOWED_VALUE]->(av);

// ---------------------------------------------------------------------------
// Attach CDEs to value domains.
// ---------------------------------------------------------------------------
UNWIND [
  {cdeId: 'CDE-CRYST-SOLVENT-COMP', valueDomainId: 'VD-NUMERIC-PERCENT-WW'},
  {cdeId: 'CDE-CRYST-SUPERSAT', valueDomainId: 'VD-NUMERIC-PERCENT'},
  {cdeId: 'CDE-CRYST-SEED-LOT', valueDomainId: 'VD-IDENTIFIER'},
  {cdeId: 'CDE-CRYST-PSD', valueDomainId: 'VD-PARTICLE-SIZE'},
  {cdeId: 'CDE-CRYST-POLYMORPH', valueDomainId: 'VD-IDENTIFIER'},
  {cdeId: 'CDE-ISO-WASH-VOLUME', valueDomainId: 'VD-MASS-KG'},
  {cdeId: 'CDE-ISO-WET-CAKE-MASS', valueDomainId: 'VD-MASS-KG'},
  {cdeId: 'CDE-DRY-LOD-ENDPOINT', valueDomainId: 'VD-NUMERIC-PERCENT'},
  {cdeId: 'CDE-DRY-RESIDUAL-SOLVENT', valueDomainId: 'VD-NUMERIC-PERCENT'},
  {cdeId: 'CDE-MILL-FEED-RATE', valueDomainId: 'VD-MASS-FLOW'},
  {cdeId: 'CDE-MILL-API-PSD', valueDomainId: 'VD-PARTICLE-SIZE'},
  {cdeId: 'CDE-API-HOLD-TIME', valueDomainId: 'VD-TIME-HOURS'},
  {cdeId: 'CDE-CDC-API-FEED-RATE', valueDomainId: 'VD-MASS-FLOW'},
  {cdeId: 'CDE-CDC-BLEND-NIR', valueDomainId: 'VD-NUMERIC-PERCENT'},
  {cdeId: 'CDE-CDC-LUB-FEED-RATE', valueDomainId: 'VD-MASS-FLOW'},
  {cdeId: 'CDE-CDC-COMPRESSION-FORCE', valueDomainId: 'VD-FORCE'},
  {cdeId: 'CDE-CDC-TABLET-WEIGHT', valueDomainId: 'VD-MASS-MG'},
  {cdeId: 'CDE-COAT-POWDER-LOT', valueDomainId: 'VD-IDENTIFIER'},
  {cdeId: 'CDE-COAT-FEED-RATE', valueDomainId: 'VD-MASS-FLOW'},
  {cdeId: 'CDE-COAT-RH', valueDomainId: 'VD-RH'},
  {cdeId: 'CDE-COAT-WEIGHT-GAIN', valueDomainId: 'VD-NUMERIC-PERCENT'},
  {cdeId: 'CDE-COAT-UNIFORMITY', valueDomainId: 'VD-NUMERIC-PERCENT'},
  {cdeId: 'CDE-COATED-CONTAINER-ID', valueDomainId: 'VD-IDENTIFIER'},
  {cdeId: 'CDE-QA-DISPOSITION', valueDomainId: 'VD-DISPOSITION'},
  {cdeId: 'CDE-CMC-SECTION-MAPPING', valueDomainId: 'VD-REGULATORY-SECTION'}
] AS row
MATCH (cde:CriticalDataElement {cdeId: row.cdeId})
MATCH (vd:ValueDomain {valueDomainId: row.valueDomainId})
MERGE (cde)-[:HAS_VALUE_DOMAIN]->(vd);

// ---------------------------------------------------------------------------
// Create concept grounding for all CDEs.
// ---------------------------------------------------------------------------
UNWIND [
  {id: 'CPP-CRYST-SOLVENT-COMP', name: 'Solvent composition', unit: '% w/w', target: 70.0, low: 65.0, high: 75.0, cdeId: 'CDE-CRYST-SOLVENT-COMP', operationId: 'UO-001-CRYSTALLISATION'},
  {id: 'CPP-CRYST-SUPERSAT', name: 'Supersaturation', unit: '%', target: 18.0, low: 12.0, high: 24.0, cdeId: 'CDE-CRYST-SUPERSAT', operationId: 'UO-001-CRYSTALLISATION'},
  {id: 'CPP-ISO-WASH-VOLUME', name: 'Wash solvent volume', unit: 'kg', target: 120.0, low: 110.0, high: 130.0, cdeId: 'CDE-ISO-WASH-VOLUME', operationId: 'UO-002-ISOLATION-WASH'},
  {id: 'CPP-MILL-FEED-RATE', name: 'Feed rate to mill', unit: 'kg/h', target: 8.0, low: 6.5, high: 9.5, cdeId: 'CDE-MILL-FEED-RATE', operationId: 'UO-004-MILLING-SIEVING'},
  {id: 'CPP-COAT-FEED-RATE', name: 'Coating powder feed rate', unit: 'kg/h', target: 1.8, low: 1.6, high: 2.0, cdeId: 'CDE-COAT-FEED-RATE', operationId: 'UO-010-POWDER-COATING'},
  {id: 'CPP-COAT-RH', name: 'Coating room relative humidity', unit: '%RH', target: 35.0, low: 25.0, high: 45.0, cdeId: 'CDE-COAT-RH', operationId: 'UO-010-POWDER-COATING'}
] AS row
MATCH (cde:CriticalDataElement {cdeId: row.cdeId})
MATCH (uo:UnitOperation {unitOperationId: row.operationId})
MERGE (cpp:CPP {cppId: row.id})
SET cpp.name = row.name,
    cpp.unit = row.unit,
    cpp.targetValue = row.target,
    cpp.lowerLimit = row.low,
    cpp.upperLimit = row.high,
    cpp.controlStrategy = 'Conceptual end-to-end process control'
MERGE (cpp)-[:CONTROLS]->(uo)
MERGE (cde)-[:DESCRIBES]->(cpp);

UNWIND [
  {id: 'CQA-CRYST-PSD', name: 'Crystal size distribution', unit: 'um', target: 75.0, cdeId: 'CDE-CRYST-PSD'},
  {id: 'CQA-CRYST-POLYMORPH', name: 'Polymorphic form', unit: '1', target: null, cdeId: 'CDE-CRYST-POLYMORPH'},
  {id: 'CQA-DRY-LOD', name: 'Loss on drying endpoint', unit: '%', target: 0.8, cdeId: 'CDE-DRY-LOD-ENDPOINT'},
  {id: 'CQA-DRY-RESIDUAL-SOLVENT', name: 'Residual solvent result', unit: '%', target: 0.25, cdeId: 'CDE-DRY-RESIDUAL-SOLVENT'},
  {id: 'CQA-COAT-WEIGHT-GAIN', name: 'Coating weight gain', unit: '%', target: 3.0, cdeId: 'CDE-COAT-WEIGHT-GAIN'},
  {id: 'CQA-COAT-UNIFORMITY', name: 'Coating uniformity', unit: '%RSD', target: 4.0, cdeId: 'CDE-COAT-UNIFORMITY'}
] AS row
MATCH (cde:CriticalDataElement {cdeId: row.cdeId})
MERGE (cqa:CQA {cqaId: row.id})
SET cqa.name = row.name,
    cqa.unit = row.unit,
    cqa.targetValue = row.target,
    cqa.patientImpact = 'Conceptual end-to-end quality attribute'
MERGE (cde)-[:DESCRIBES]->(cqa);

UNWIND [
  {cdeId: 'CDE-CRYST-SEED-LOT', conceptLabel: 'IntermediateProduct', conceptId: 'IP-CRYSTALLINE-SLURRY'},
  {cdeId: 'CDE-ISO-WET-CAKE-MASS', conceptLabel: 'IntermediateProduct', conceptId: 'IP-WET-CAKE'},
  {cdeId: 'CDE-API-HOLD-TIME', conceptLabel: 'IntermediateProduct', conceptId: 'IP-MILLED-API'},
  {cdeId: 'CDE-COAT-POWDER-LOT', conceptLabel: 'IntermediateProduct', conceptId: 'IP-CORE-TABLET'},
  {cdeId: 'CDE-COATED-CONTAINER-ID', conceptLabel: 'IntermediateProduct', conceptId: 'IP-POWDER-COATED-TABLET'},
  {cdeId: 'CDE-CMC-SECTION-MAPPING', conceptLabel: 'CMCPackage', conceptId: 'CMC-AZD-CDC-10MG-001'}
] AS row
MATCH (cde:CriticalDataElement {cdeId: row.cdeId})
CALL {
  WITH row
  OPTIONAL MATCH (ip:IntermediateProduct {intermediateProductId: row.conceptId})
  WHERE row.conceptLabel = 'IntermediateProduct'
  RETURN ip AS concept
  UNION
  WITH row
  OPTIONAL MATCH (cmc:CMCPackage {cmcPackageId: row.conceptId})
  WHERE row.conceptLabel = 'CMCPackage'
  RETURN cmc AS concept
}
WITH cde, concept
WHERE concept IS NOT NULL
MERGE (cde)-[:DESCRIBES]->(concept);

// ---------------------------------------------------------------------------
// Definition versions and approval records.
// ---------------------------------------------------------------------------
MATCH (cde:CriticalDataElement)
MERGE (version:CDEVersion {cdeVersionId: cde.cdeId + '-V1'})
SET version.version = '1.0',
    version.status = 'Approved for demo',
    version.effectiveFrom = date('2026-06-01'),
    version.definitionText = cde.definition
MERGE (cde)-[:HAS_VERSION]->(version);

MATCH (cde:CriticalDataElement)-[:HAS_VERSION]->(version:CDEVersion)
MATCH (owner:DataOwner)<-[:HAS_OWNER]-(cde)
MERGE (approval:CDEDefinitionApproval {approvalId: cde.cdeId + '-APPROVAL-V1'})
SET approval.status = 'Approved for reference architecture',
    approval.approvedAt = date('2026-06-03'),
    approval.approvalMeaning = 'CDE definition accepted for demo AI-readiness review'
MERGE (version)-[:APPROVED_BY]->(approval)
MERGE (approval)-[:APPROVED_BY_OWNER]->(owner);

// ---------------------------------------------------------------------------
// Representative CDE values for grounding and retrieval.
// ---------------------------------------------------------------------------
UNWIND [
  {cdeId: 'CDE-CRYST-SOLVENT-COMP', value: 70.2, text: null, ts: '2026-06-01T03:00:00+01:00', status: 'In specification'},
  {cdeId: 'CDE-CRYST-SUPERSAT', value: 18.6, text: null, ts: '2026-06-01T03:10:00+01:00', status: 'In specification'},
  {cdeId: 'CDE-CRYST-SEED-LOT', value: null, text: 'SEED-AZD-260501-A', ts: '2026-06-01T03:12:00+01:00', status: 'Verified'},
  {cdeId: 'CDE-CRYST-PSD', value: 74.0, text: null, ts: '2026-06-01T04:15:00+01:00', status: 'In specification'},
  {cdeId: 'CDE-CRYST-POLYMORPH', value: null, text: 'Form A', ts: '2026-06-01T04:30:00+01:00', status: 'Conforms'},
  {cdeId: 'CDE-ISO-WASH-VOLUME', value: 121.5, text: null, ts: '2026-06-01T05:00:00+01:00', status: 'In specification'},
  {cdeId: 'CDE-ISO-WET-CAKE-MASS', value: 18.4, text: null, ts: '2026-06-01T05:45:00+01:00', status: 'Recorded'},
  {cdeId: 'CDE-DRY-LOD-ENDPOINT', value: 0.72, text: null, ts: '2026-06-01T06:30:00+01:00', status: 'In specification'},
  {cdeId: 'CDE-DRY-RESIDUAL-SOLVENT', value: 0.18, text: null, ts: '2026-06-01T06:45:00+01:00', status: 'In specification'},
  {cdeId: 'CDE-MILL-FEED-RATE', value: 8.1, text: null, ts: '2026-06-01T07:10:00+01:00', status: 'In specification'},
  {cdeId: 'CDE-MILL-API-PSD', value: 42.0, text: null, ts: '2026-06-01T07:30:00+01:00', status: 'In specification'},
  {cdeId: 'CDE-API-HOLD-TIME', value: 1.5, text: null, ts: '2026-06-01T07:45:00+01:00', status: 'Within approved hold'},
  {cdeId: 'CDE-CDC-API-FEED-RATE', value: 1.24, text: null, ts: '2026-06-01T08:15:00+01:00', status: 'In specification'},
  {cdeId: 'CDE-CDC-BLEND-NIR', value: 5.6, text: null, ts: '2026-06-01T10:20:00+01:00', status: 'Out of specification'},
  {cdeId: 'CDE-CDC-LUB-FEED-RATE', value: 0.50, text: null, ts: '2026-06-01T09:45:00+01:00', status: 'In specification'},
  {cdeId: 'CDE-CDC-COMPRESSION-FORCE', value: 12.4, text: null, ts: '2026-06-01T11:15:00+01:00', status: 'In specification'},
  {cdeId: 'CDE-CDC-TABLET-WEIGHT', value: 211.2, text: null, ts: '2026-06-01T12:30:00+01:00', status: 'Out of specification'},
  {cdeId: 'CDE-COAT-POWDER-LOT', value: null, text: 'COAT-POWDER-260515-01', ts: '2026-06-01T14:45:00+01:00', status: 'Verified'},
  {cdeId: 'CDE-COAT-FEED-RATE', value: 1.82, text: null, ts: '2026-06-01T15:00:00+01:00', status: 'In specification'},
  {cdeId: 'CDE-COAT-RH', value: 38.0, text: null, ts: '2026-06-01T15:05:00+01:00', status: 'In specification'},
  {cdeId: 'CDE-COAT-WEIGHT-GAIN', value: 3.1, text: null, ts: '2026-06-01T16:00:00+01:00', status: 'In specification'},
  {cdeId: 'CDE-COAT-UNIFORMITY', value: 3.8, text: null, ts: '2026-06-01T16:15:00+01:00', status: 'In specification'},
  {cdeId: 'CDE-COATED-CONTAINER-ID', value: null, text: 'COATED-TAB-CONT-260601-01', ts: '2026-06-01T16:45:00+01:00', status: 'Recorded'},
  {cdeId: 'CDE-QA-DISPOSITION', value: null, text: 'Release', ts: '2026-06-02T11:00:00+01:00', status: 'Approved'},
  {cdeId: 'CDE-CMC-SECTION-MAPPING', value: null, text: 'CTD-3.2.P.3.4', ts: '2026-06-02T12:00:00+01:00', status: 'Mapped'}
] AS row
MATCH (cde:CriticalDataElement {cdeId: row.cdeId})
MATCH (vd:ValueDomain)<-[:HAS_VALUE_DOMAIN]-(cde)
OPTIONAL MATCH (run:ManufacturingRun {runId: 'RUN-CDC-2026-06-01-001'})
MERGE (value:CDEValue {cdeValueId: row.cdeId + '-RUN-CDC-2026-06-01-001'})
SET value.numericValue = row.value,
    value.textValue = row.text,
    value.timestamp = datetime(row.ts),
    value.status = row.status,
    value.demoValue = true
MERGE (value)-[:VALUE_OF]->(cde)
MERGE (value)-[:CONFORMS_TO_VALUE_DOMAIN]->(vd)
FOREACH (_ IN CASE WHEN run IS NULL THEN [] ELSE [1] END |
  MERGE (value)-[:OBSERVED_DURING]->(run)
);

// Additional CDE value series to support trend-style AI questions.
// These are simulated demo observations, not validated manufacturing data.
UNWIND [
  {id: 'CDE-CRYST-SUPERSAT-RUN-CDC-2026-06-01-001-TP01', cdeId: 'CDE-CRYST-SUPERSAT', value: 14.2, text: null, ts: '2026-06-01T03:00:00+01:00', status: 'In specification', samplePoint: 'Crystallisation ramp TP01', sequence: 1, evidenceType: 'Simulated process value'},
  {id: 'CDE-CRYST-SUPERSAT-RUN-CDC-2026-06-01-001-TP02', cdeId: 'CDE-CRYST-SUPERSAT', value: 18.6, text: null, ts: '2026-06-01T03:10:00+01:00', status: 'In specification', samplePoint: 'Crystallisation ramp TP02', sequence: 2, evidenceType: 'Simulated process value'},
  {id: 'CDE-CRYST-SUPERSAT-RUN-CDC-2026-06-01-001-TP03', cdeId: 'CDE-CRYST-SUPERSAT', value: 21.4, text: null, ts: '2026-06-01T03:20:00+01:00', status: 'In specification', samplePoint: 'Crystallisation ramp TP03', sequence: 3, evidenceType: 'Simulated process value'},
  {id: 'CDE-CRYST-PSD-RUN-CDC-2026-06-01-001-SAMPLE01', cdeId: 'CDE-CRYST-PSD', value: 68.0, text: null, ts: '2026-06-01T04:00:00+01:00', status: 'In specification', samplePoint: 'Crystal slurry sample 01', sequence: 1, evidenceType: 'Simulated lab result'},
  {id: 'CDE-CRYST-PSD-RUN-CDC-2026-06-01-001-SAMPLE02', cdeId: 'CDE-CRYST-PSD', value: 74.0, text: null, ts: '2026-06-01T04:15:00+01:00', status: 'In specification', samplePoint: 'Crystal slurry sample 02', sequence: 2, evidenceType: 'Simulated lab result'},
  {id: 'CDE-DRY-LOD-ENDPOINT-RUN-CDC-2026-06-01-001-TP01', cdeId: 'CDE-DRY-LOD-ENDPOINT', value: 1.45, text: null, ts: '2026-06-01T06:00:00+01:00', status: 'Drying in progress', samplePoint: 'Dryer endpoint TP01', sequence: 1, evidenceType: 'Simulated lab result'},
  {id: 'CDE-DRY-LOD-ENDPOINT-RUN-CDC-2026-06-01-001-TP02', cdeId: 'CDE-DRY-LOD-ENDPOINT', value: 0.92, text: null, ts: '2026-06-01T06:15:00+01:00', status: 'Approaching endpoint', samplePoint: 'Dryer endpoint TP02', sequence: 2, evidenceType: 'Simulated lab result'},
  {id: 'CDE-DRY-LOD-ENDPOINT-RUN-CDC-2026-06-01-001-TP03', cdeId: 'CDE-DRY-LOD-ENDPOINT', value: 0.72, text: null, ts: '2026-06-01T06:30:00+01:00', status: 'In specification', samplePoint: 'Dryer endpoint TP03', sequence: 3, evidenceType: 'Simulated lab result'},
  {id: 'CDE-MILL-FEED-RATE-RUN-CDC-2026-06-01-001-TP01', cdeId: 'CDE-MILL-FEED-RATE', value: 7.8, text: null, ts: '2026-06-01T07:05:00+01:00', status: 'In specification', samplePoint: 'Mill feed TP01', sequence: 1, evidenceType: 'Simulated equipment value'},
  {id: 'CDE-MILL-FEED-RATE-RUN-CDC-2026-06-01-001-TP02', cdeId: 'CDE-MILL-FEED-RATE', value: 8.1, text: null, ts: '2026-06-01T07:10:00+01:00', status: 'In specification', samplePoint: 'Mill feed TP02', sequence: 2, evidenceType: 'Simulated equipment value'},
  {id: 'CDE-MILL-FEED-RATE-RUN-CDC-2026-06-01-001-TP03', cdeId: 'CDE-MILL-FEED-RATE', value: 8.4, text: null, ts: '2026-06-01T07:15:00+01:00', status: 'In specification', samplePoint: 'Mill feed TP03', sequence: 3, evidenceType: 'Simulated equipment value'},
  {id: 'CDE-MILL-API-PSD-RUN-CDC-2026-06-01-001-SAMPLE01', cdeId: 'CDE-MILL-API-PSD', value: 45.0, text: null, ts: '2026-06-01T07:20:00+01:00', status: 'In specification', samplePoint: 'Post-mill sample 01', sequence: 1, evidenceType: 'Simulated lab result'},
  {id: 'CDE-MILL-API-PSD-RUN-CDC-2026-06-01-001-SAMPLE02', cdeId: 'CDE-MILL-API-PSD', value: 42.0, text: null, ts: '2026-06-01T07:30:00+01:00', status: 'In specification', samplePoint: 'Post-mill sample 02', sequence: 2, evidenceType: 'Simulated lab result'},
  {id: 'CDE-COAT-FEED-RATE-RUN-CDC-2026-06-01-001-TP01', cdeId: 'CDE-COAT-FEED-RATE', value: 1.75, text: null, ts: '2026-06-01T15:00:00+01:00', status: 'In specification', samplePoint: 'Coating feed TP01', sequence: 1, evidenceType: 'Simulated equipment value'},
  {id: 'CDE-COAT-FEED-RATE-RUN-CDC-2026-06-01-001-TP02', cdeId: 'CDE-COAT-FEED-RATE', value: 1.82, text: null, ts: '2026-06-01T15:15:00+01:00', status: 'In specification', samplePoint: 'Coating feed TP02', sequence: 2, evidenceType: 'Simulated equipment value'},
  {id: 'CDE-COAT-FEED-RATE-RUN-CDC-2026-06-01-001-TP03', cdeId: 'CDE-COAT-FEED-RATE', value: 1.88, text: null, ts: '2026-06-01T15:30:00+01:00', status: 'In specification', samplePoint: 'Coating feed TP03', sequence: 3, evidenceType: 'Simulated equipment value'},
  {id: 'CDE-COAT-RH-RUN-CDC-2026-06-01-001-TP01', cdeId: 'CDE-COAT-RH', value: 34.0, text: null, ts: '2026-06-01T15:05:00+01:00', status: 'In specification', samplePoint: 'Coating suite RH TP01', sequence: 1, evidenceType: 'Simulated environmental value'},
  {id: 'CDE-COAT-RH-RUN-CDC-2026-06-01-001-TP02', cdeId: 'CDE-COAT-RH', value: 38.0, text: null, ts: '2026-06-01T15:20:00+01:00', status: 'In specification', samplePoint: 'Coating suite RH TP02', sequence: 2, evidenceType: 'Simulated environmental value'},
  {id: 'CDE-COAT-RH-RUN-CDC-2026-06-01-001-TP03', cdeId: 'CDE-COAT-RH', value: 42.0, text: null, ts: '2026-06-01T15:35:00+01:00', status: 'In specification', samplePoint: 'Coating suite RH TP03', sequence: 3, evidenceType: 'Simulated environmental value'},
  {id: 'CDE-COAT-WEIGHT-GAIN-RUN-CDC-2026-06-01-001-TP01', cdeId: 'CDE-COAT-WEIGHT-GAIN', value: 1.2, text: null, ts: '2026-06-01T15:20:00+01:00', status: 'In process', samplePoint: 'Coating weight gain TP01', sequence: 1, evidenceType: 'Simulated in-process check'},
  {id: 'CDE-COAT-WEIGHT-GAIN-RUN-CDC-2026-06-01-001-TP02', cdeId: 'CDE-COAT-WEIGHT-GAIN', value: 2.4, text: null, ts: '2026-06-01T15:40:00+01:00', status: 'In process', samplePoint: 'Coating weight gain TP02', sequence: 2, evidenceType: 'Simulated in-process check'},
  {id: 'CDE-COAT-WEIGHT-GAIN-RUN-CDC-2026-06-01-001-TP03', cdeId: 'CDE-COAT-WEIGHT-GAIN', value: 3.1, text: null, ts: '2026-06-01T16:00:00+01:00', status: 'In specification', samplePoint: 'Coating weight gain TP03', sequence: 3, evidenceType: 'Simulated in-process check'},
  {id: 'CDE-COAT-UNIFORMITY-RUN-CDC-2026-06-01-001-SAMPLE01', cdeId: 'CDE-COAT-UNIFORMITY', value: 4.6, text: null, ts: '2026-06-01T15:45:00+01:00', status: 'In specification', samplePoint: 'Coating uniformity sample 01', sequence: 1, evidenceType: 'Simulated lab result'},
  {id: 'CDE-COAT-UNIFORMITY-RUN-CDC-2026-06-01-001-SAMPLE02', cdeId: 'CDE-COAT-UNIFORMITY', value: 4.1, text: null, ts: '2026-06-01T16:00:00+01:00', status: 'In specification', samplePoint: 'Coating uniformity sample 02', sequence: 2, evidenceType: 'Simulated lab result'},
  {id: 'CDE-COAT-UNIFORMITY-RUN-CDC-2026-06-01-001-SAMPLE03', cdeId: 'CDE-COAT-UNIFORMITY', value: 3.8, text: null, ts: '2026-06-01T16:15:00+01:00', status: 'In specification', samplePoint: 'Coating uniformity sample 03', sequence: 3, evidenceType: 'Simulated lab result'}
] AS row
MATCH (cde:CriticalDataElement {cdeId: row.cdeId})
MATCH (vd:ValueDomain)<-[:HAS_VALUE_DOMAIN]-(cde)
OPTIONAL MATCH (run:ManufacturingRun {runId: 'RUN-CDC-2026-06-01-001'})
MERGE (value:CDEValue {cdeValueId: row.id})
SET value.numericValue = row.value,
    value.textValue = row.text,
    value.timestamp = datetime(row.ts),
    value.status = row.status,
    value.samplePoint = row.samplePoint,
    value.sequence = row.sequence,
    value.evidenceType = row.evidenceType,
    value.demoValue = true,
    value.demoSeries = true
MERGE (value)-[:VALUE_OF]->(cde)
MERGE (value)-[:CONFORMS_TO_VALUE_DOMAIN]->(vd)
FOREACH (_ IN CASE WHEN run IS NULL THEN [] ELSE [1] END |
  MERGE (value)-[:OBSERVED_DURING]->(run)
);

// Link CDE values to existing sensor readings where the demo has concrete readings.
UNWIND [
  {cdeValueId: 'CDE-CDC-API-FEED-RATE-RUN-CDC-2026-06-01-001', readingId: 'READ-API-FR-0800'},
  {cdeValueId: 'CDE-CDC-BLEND-NIR-RUN-CDC-2026-06-01-001', readingId: 'READ-NIR-BU-1020'},
  {cdeValueId: 'CDE-CDC-COMPRESSION-FORCE-RUN-CDC-2026-06-01-001', readingId: 'READ-COMP-FORCE-1115'},
  {cdeValueId: 'CDE-CDC-TABLET-WEIGHT-RUN-CDC-2026-06-01-001', readingId: 'READ-WEIGHT-1230'}
] AS row
MATCH (value:CDEValue {cdeValueId: row.cdeValueId})
MATCH (reading:SensorReading {readingId: row.readingId})
MERGE (value)-[:DERIVED_FROM_READING]->(reading);

// ---------------------------------------------------------------------------
// Provenance statements for standards and mappings.
// ---------------------------------------------------------------------------
UNWIND [
  {id: 'PROV-ICH-Q13-FDA', standardId: 'STD-ICH-Q13', sourceUrl: 'https://www.fda.gov/regulatory-information/search-fda-guidance-documents/q13-continuous-manufacturing-drug-substances-and-drug-products', citation: 'FDA guidance page for ICH Q13 Continuous Manufacturing of Drug Substances and Drug Products', confidence: 'High'},
  {id: 'PROV-ICH-Q10-EMA', standardId: 'STD-ICH-Q10', sourceUrl: 'https://www.ema.europa.eu/en/ich-q10-pharmaceutical-quality-system-scientific-guideline', citation: 'EMA page for ICH Q10 Pharmaceutical Quality System', confidence: 'High'},
  {id: 'PROV-ICH-Q11-FDA', standardId: 'STD-ICH-Q11', sourceUrl: 'https://www.fda.gov/regulatory-information/search-fda-guidance-documents/q11-development-and-manufacture-drug-substances', citation: 'FDA guidance page for ICH Q11 Development and Manufacture of Drug Substances', confidence: 'High'},
  {id: 'PROV-ICH-Q12-FDA', standardId: 'STD-ICH-Q12', sourceUrl: 'https://www.fda.gov/regulatory-information/search-fda-guidance-documents/q12-technical-and-regulatory-considerations-pharmaceutical-product-lifecycle-management', citation: 'FDA guidance page for ICH Q12 Pharmaceutical Product Lifecycle Management', confidence: 'High'},
  {id: 'PROV-ICH-CTD', standardId: 'STD-CTD-M3', sourceUrl: 'https://admin.ich.org/page/ctd', citation: 'ICH CTD page describing the Common Technical Document structure', confidence: 'High'},
  {id: 'PROV-ICH-Q14-FDA', standardId: 'STD-ICH-Q14', sourceUrl: 'https://www.fda.gov/regulatory-information/search-fda-guidance-documents/q14-analytical-procedure-development', citation: 'FDA guidance page for ICH Q14 Analytical Procedure Development', confidence: 'High'},
  {id: 'PROV-ISO-11179-1', standardId: 'STD-ISO-11179', sourceUrl: 'https://www.iso.org/standard/78914.html', citation: 'ISO/IEC 11179-1:2023 metadata registry framework', confidence: 'High'},
  {id: 'PROV-ISO-14644-1', standardId: 'STD-ISO-14644', sourceUrl: 'https://www.iso.org/standard/53394.html', citation: 'ISO 14644-1 cleanroom classification standard page', confidence: 'High'},
  {id: 'PROV-ISO-22400-1', standardId: 'STD-ISO-22400', sourceUrl: 'https://www.iso.org/standard/56847.html', citation: 'ISO 22400-1 manufacturing operations KPI standard page', confidence: 'High'},
  {id: 'PROV-ISA-95', standardId: 'STD-ISA-95', sourceUrl: 'https://www.isa.org/standards-and-publications/isa-standards/isa-95-standard', citation: 'ISA-95 enterprise-control system integration standard page', confidence: 'High'}
] AS row
MATCH (standard:DataStandard {standardId: row.standardId})
MERGE (prov:ProvenanceStatement {provenanceId: row.id})
SET prov.sourceUrl = row.sourceUrl,
    prov.citation = row.citation,
    prov.confidence = row.confidence,
    prov.retrievedAt = date('2026-06-03'),
    prov.provenanceType = 'Standards source'
MERGE (standard)-[:HAS_PROVENANCE]->(prov);

MATCH (mapping:StandardMapping)-[:TO_STANDARD]->(standard:DataStandard)-[:HAS_PROVENANCE]->(prov:ProvenanceStatement)
MERGE (mapping)-[:SUPPORTED_BY_PROVENANCE]->(prov)
SET mapping.mappingConfidence = coalesce(mapping.mappingConfidence, prov.confidence),
    mapping.reviewStatus = coalesce(mapping.reviewStatus, 'Reference reviewed'),
    mapping.reviewedAt = coalesce(mapping.reviewedAt, date('2026-06-03'));

// ---------------------------------------------------------------------------
// Evidence documents for explicit AI/regulatory grounding.
// These are fictional demo document records, not validated GxP evidence.
// ---------------------------------------------------------------------------
UNWIND [
  {id: 'EVDOC-BMR-RUN-260601', title: 'Demo electronic batch record extract for AZDCDC10-260601', type: 'Batch record extract', status: 'Demo reviewed', system: 'MES demo', uri: 'demo://ebr/AZDCDC10-260601', summary: 'Fictional batch record extract covering genealogy, CPP review, deviation closure, and QA release.'},
  {id: 'EVDOC-NIR-BU-260601', title: 'Demo NIR blend uniformity trend extract', type: 'PAT trend extract', status: 'Demo reviewed', system: 'PAT historian demo', uri: 'demo://pat/nir-blend-uniformity/RUN-CDC-2026-06-01-001', summary: 'Fictional trend evidence for inline NIR blend uniformity and associated alarm investigation.'},
  {id: 'EVDOC-COAT-WG-260601', title: 'Demo coating weight gain in-process check sheet', type: 'IPC record extract', status: 'Demo reviewed', system: 'MES demo', uri: 'demo://ipc/coating-weight-gain/RUN-CDC-2026-06-01-001', summary: 'Fictional in-process check evidence for semi-continuous powder coating weight gain.'},
  {id: 'EVDOC-CTD-3234-MAP', title: 'Demo CTD 3.2.P.3.4 CDE traceability matrix', type: 'CMC traceability matrix', status: 'Reference architecture reviewed', system: 'Regulatory information management demo', uri: 'demo://cmc/ctd-3.2.p.3.4/cde-traceability', summary: 'Fictional matrix linking selected CDEs to CTD Module 3 controls of critical steps and intermediates.'},
  {id: 'EVDOC-STD-PROV-MAP', title: 'Demo standards provenance review pack', type: 'Standards provenance pack', status: 'Reference architecture reviewed', system: 'Data governance demo', uri: 'demo://governance/standards-provenance', summary: 'Fictional pack showing why CDEs map to ICH, ISO, ISA-95, and CTD reference concepts.'},
  {id: 'EVDOC-REJECT-RUN-260602', title: 'Demo rejected run QA disposition extract for AZDCDC10-260602', type: 'QA disposition extract', status: 'Demo reviewed', system: 'QMS demo', uri: 'demo://qa-disposition/AZDCDC10-260602', summary: 'Fictional QA decision evidence for a rejected/quarantined demonstration run.'}
] AS row
MERGE (doc:EvidenceDocument {documentId: row.id})
SET doc.title = row.title,
    doc.documentType = row.type,
    doc.status = row.status,
    doc.sourceSystem = row.system,
    doc.uri = row.uri,
    doc.summary = row.summary,
    doc.demoOnly = true,
    doc.effectiveDate = date('2026-06-03');

MATCH (doc:EvidenceDocument {documentId: 'EVDOC-BMR-RUN-260601'})
MATCH (br:BatchRecord {batchRecordId: 'BR-AZDCDC10-260601'})
MATCH (decision:QAReleaseDecision {decisionId: 'QA-REL-AZDCDC10-260601'})
MATCH (run:ManufacturingRun {runId: 'RUN-CDC-2026-06-01-001'})
MERGE (doc)-[:DOCUMENTS_BATCH_RECORD]->(br)
MERGE (doc)-[:DOCUMENTS_QA_DECISION]->(decision)
MERGE (doc)-[:DOCUMENTS_RUN]->(run);

MATCH (doc:EvidenceDocument {documentId: 'EVDOC-NIR-BU-260601'})
MATCH (value:CDEValue {cdeValueId: 'CDE-CDC-BLEND-NIR-RUN-CDC-2026-06-01-001'})
MATCH (reading:SensorReading {readingId: 'READ-NIR-BU-1020'})
MATCH (dev:Deviation {deviationId: 'DEV-CDC-20260601-001'})
MERGE (doc)-[:EVIDENCES_CDE_VALUE]->(value)
MERGE (doc)-[:EVIDENCES_READING]->(reading)
MERGE (doc)-[:SUPPORTS_DEVIATION]->(dev);

MATCH (doc:EvidenceDocument {documentId: 'EVDOC-COAT-WG-260601'})
MATCH (cde:CriticalDataElement {cdeId: 'CDE-COAT-WEIGHT-GAIN'})
MERGE (doc)-[:EVIDENCES_CDE]->(cde)
WITH doc
MATCH (value:CDEValue)-[:VALUE_OF]->(:CriticalDataElement {cdeId: 'CDE-COAT-WEIGHT-GAIN'})
MERGE (doc)-[:EVIDENCES_CDE_VALUE]->(value);

MATCH (doc:EvidenceDocument {documentId: 'EVDOC-CTD-3234-MAP'})
MATCH (section:RegulatorySection {sectionId: 'CTD-3.2.P.3.4'})
MERGE (doc)-[:SUPPORTS_CMC_SECTION]->(section)
WITH doc
MATCH (mapping:StandardMapping)-[:TO_REGULATORY_SECTION]->(:RegulatorySection {sectionId: 'CTD-3.2.P.3.4'})
MERGE (doc)-[:SUPPORTS_MAPPING]->(mapping);

MATCH (doc:EvidenceDocument {documentId: 'EVDOC-STD-PROV-MAP'})
MATCH (filing:RegulatoryFiling {filingId: 'REG-FILING-AZD-CDC-DEMO-001'})
MERGE (doc)-[:SUPPORTS_FILING]->(filing)
WITH doc
MATCH (mapping:StandardMapping)
MERGE (doc)-[:SUPPORTS_MAPPING]->(mapping);

MATCH (doc:EvidenceDocument {documentId: 'EVDOC-REJECT-RUN-260602'})
MATCH (br:BatchRecord {batchRecordId: 'BR-AZDCDC10-260602'})
MATCH (decision:QAReleaseDecision {decisionId: 'QA-REJ-AZDCDC10-260602'})
MATCH (run:ManufacturingRun {runId: 'RUN-CDC-2026-06-02-002'})
MERGE (doc)-[:DOCUMENTS_BATCH_RECORD]->(br)
MERGE (doc)-[:DOCUMENTS_QA_DECISION]->(decision)
MERGE (doc)-[:DOCUMENTS_RUN]->(run);

MATCH (evidence:ValidationEvidence)
MATCH (doc:EvidenceDocument {documentId: 'EVDOC-STD-PROV-MAP'})
MERGE (doc)-[:SUPPORTS_VALIDATION_EVIDENCE]->(evidence);

// ---------------------------------------------------------------------------
// Controlled vocabularies as graph nodes for queryable reference data.
// ---------------------------------------------------------------------------
UNWIND [
  {id: 'CDEDOMAIN-CPP', value: 'CPP', description: 'Critical process parameter data.'},
  {id: 'CDEDOMAIN-CQA', value: 'CQA', description: 'Critical quality attribute data.'},
  {id: 'CDEDOMAIN-CMA', value: 'CMA', description: 'Critical material attribute data.'},
  {id: 'CDEDOMAIN-GENEALOGY', value: 'Genealogy', description: 'Material, lot, container, and lineage data.'},
  {id: 'CDEDOMAIN-QMS', value: 'QMS', description: 'Quality management system and disposition data.'},
  {id: 'CDEDOMAIN-REGULATORY', value: 'Regulatory metadata', description: 'CMC and regulatory traceability metadata.'}
] AS row
MERGE (domain:CDEDomain {domainId: row.id})
SET domain.name = row.value,
    domain.description = row.description;

UNWIND [
  {id: 'CRIT-CRITICAL', value: 'Critical', description: 'Required for quality, control, disposition, genealogy, or regulatory evidence.'},
  {id: 'CRIT-IMPORTANT', value: 'Important', description: 'Useful for interpretation, investigation, monitoring, or analytics.'}
] AS row
MERGE (criticality:CriticalityLevel {criticalityId: row.id})
SET criticality.name = row.value,
    criticality.description = row.description;

UNWIND [
  {id: 'DECISION-RELEASE', value: 'Release', description: 'QA decision releases the run for intended demo use.'},
  {id: 'DECISION-REJECT', value: 'Reject', description: 'QA decision rejects/quarantines the run in demo data.'},
  {id: 'DECISION-APPROVED', value: 'Approved', description: 'Decision record has completed demo review.'}
] AS row
MERGE (status:DecisionStatus {decisionStatusId: row.id})
SET status.name = row.value,
    status.description = row.description;

UNWIND [
  {id: 'DEVSEV-MAJOR', value: 'Major', description: 'Potential quality impact requiring formal investigation.'},
  {id: 'DEVSEV-CRITICAL', value: 'Critical', description: 'Serious excursion with rejected or quarantined demo material.'}
] AS row
MERGE (severity:DeviationSeverity {severityId: row.id})
SET severity.name = row.value,
    severity.description = row.description;

UNWIND [
  {id: 'RUNSTATUS-RELEASED', value: 'Released', description: 'Run has approved release disposition.'},
  {id: 'RUNSTATUS-REJECTED', value: 'Rejected', description: 'Run has rejected/quarantined disposition.'}
] AS row
MERGE (status:RunStatus {runStatusId: row.id})
SET status.name = row.value,
    status.description = row.description;

MATCH (cde:CriticalDataElement)
MATCH (criticality:CriticalityLevel {criticalityId: 'CRIT-' + toUpper(cde.criticality)})
MERGE (cde)-[:HAS_CRITICALITY_LEVEL]->(criticality);

MATCH (cde:CriticalDataElement)
WITH cde,
     CASE
       WHEN cde.domain CONTAINS 'CPP' THEN 'CDEDOMAIN-CPP'
       WHEN cde.domain CONTAINS 'CQA' THEN 'CDEDOMAIN-CQA'
       WHEN cde.domain CONTAINS 'CMA' THEN 'CDEDOMAIN-CMA'
       WHEN cde.domain CONTAINS 'Genealogy' THEN 'CDEDOMAIN-GENEALOGY'
       WHEN cde.domain CONTAINS 'Disposition' THEN 'CDEDOMAIN-QMS'
       WHEN cde.domain CONTAINS 'Regulatory' THEN 'CDEDOMAIN-REGULATORY'
       ELSE 'CDEDOMAIN-QMS'
     END AS domainId
MATCH (domain:CDEDomain {domainId: domainId})
MERGE (cde)-[:HAS_CDE_DOMAIN]->(domain);

MATCH (run:ManufacturingRun)
WITH run, CASE WHEN run.status = 'Released' THEN 'RUNSTATUS-RELEASED' ELSE 'RUNSTATUS-REJECTED' END AS statusId
MATCH (status:RunStatus {runStatusId: statusId})
MERGE (run)-[:HAS_RUN_STATUS]->(status);

MATCH (decision:QAReleaseDecision)
WITH decision, CASE WHEN decision.decision = 'Release' THEN 'DECISION-RELEASE' ELSE 'DECISION-REJECT' END AS decisionStatusId
MATCH (status:DecisionStatus {decisionStatusId: decisionStatusId})
MERGE (decision)-[:HAS_DECISION_STATUS]->(status);

MATCH (decision:QAReleaseDecision {status: 'Approved'})
MATCH (status:DecisionStatus {decisionStatusId: 'DECISION-APPROVED'})
MERGE (decision)-[:HAS_DECISION_STATUS]->(status);

MATCH (dev:Deviation)
WITH dev, CASE WHEN dev.severity = 'Critical' THEN 'DEVSEV-CRITICAL' ELSE 'DEVSEV-MAJOR' END AS severityId
MATCH (severity:DeviationSeverity {severityId: severityId})
MERGE (dev)-[:HAS_DEVIATION_SEVERITY]->(severity);

// ---------------------------------------------------------------------------
// Relationship definitions for Neo4j-to-ontology alignment.
// ---------------------------------------------------------------------------
UNWIND [
  {id: 'RELDEF-HAS_FORMULATION', neo4jType: 'HAS_FORMULATION', predicate: 'hasFormulation', subject: 'Product', object: 'Formulation', description: 'Product has a governed formulation.'},
  {id: 'RELDEF-USES_MATERIAL', neo4jType: 'USES_MATERIAL', predicate: 'usesMaterial', subject: 'Formulation', object: 'Material', description: 'Formulation uses a material master.'},
  {id: 'RELDEF-DEFINES_STEP', neo4jType: 'DEFINES_STEP', predicate: 'definesStep', subject: 'Recipe', object: 'ProcessStep', description: 'Recipe defines an ordered process step.'},
  {id: 'RELDEF-EXECUTES', neo4jType: 'EXECUTES', predicate: 'executes', subject: 'ManufacturingRun', object: 'Recipe', description: 'Manufacturing run executes a recipe.'},
  {id: 'RELDEF-CONSUMES', neo4jType: 'CONSUMES', predicate: 'consumes', subject: 'ManufacturingRun', object: 'MaterialLot', description: 'Manufacturing run consumes a material lot.'},
  {id: 'RELDEF-INSTANCE_OF', neo4jType: 'INSTANCE_OF', predicate: 'instanceOf', subject: 'MaterialLot', object: 'Material', description: 'Material lot instantiates a material master.'},
  {id: 'RELDEF-RECORDED_BY', neo4jType: 'RECORDED_BY', predicate: 'recordedBy', subject: 'SensorReading', object: 'Sensor', description: 'Sensor reading was recorded by a sensor.'},
  {id: 'RELDEF-DURING_RUN', neo4jType: 'DURING_RUN', predicate: 'duringRun', subject: 'SensorReading', object: 'ManufacturingRun', description: 'Sensor reading occurred during a run.'},
  {id: 'RELDEF-RELEASES', neo4jType: 'RELEASES', predicate: 'releases', subject: 'QAReleaseDecision', object: 'ManufacturingRun', description: 'QA decision releases a manufacturing run.'},
  {id: 'RELDEF-REJECTS', neo4jType: 'REJECTS', predicate: 'rejects', subject: 'QAReleaseDecision', object: 'ManufacturingRun', description: 'QA decision rejects a manufacturing run.'},
  {id: 'RELDEF-VALUE_OF', neo4jType: 'VALUE_OF', predicate: 'valueOf', subject: 'CDEValue', object: 'CriticalDataElement', description: 'Observed value instantiates a CDE definition.'},
  {id: 'RELDEF-CONFORMS_TO_VALUE_DOMAIN', neo4jType: 'CONFORMS_TO_VALUE_DOMAIN', predicate: 'conformsToValueDomain', subject: 'CDEValue', object: 'ValueDomain', description: 'Observed value is interpreted by a value domain.'},
  {id: 'RELDEF-SUPPORTED_BY_PROVENANCE', neo4jType: 'SUPPORTED_BY_PROVENANCE', predicate: 'supportedByProvenance', subject: 'StandardMapping', object: 'ProvenanceStatement', description: 'Standard mapping has provenance support.'},
  {id: 'RELDEF-SUPPORTS_MAPPING', neo4jType: 'SUPPORTS_MAPPING', predicate: 'supportsMapping', subject: 'EvidenceDocument', object: 'StandardMapping', description: 'Evidence document supports a standard mapping.'},
  {id: 'RELDEF-EVIDENCES_CDE_VALUE', neo4jType: 'EVIDENCES_CDE_VALUE', predicate: 'evidencesCDEValue', subject: 'EvidenceDocument', object: 'CDEValue', description: 'Evidence document supports an observed CDE value.'}
] AS row
MERGE (rel:RelationshipDefinition {relationshipDefinitionId: row.id})
SET rel.neo4jType = row.neo4jType,
    rel.ontologyPredicate = row.predicate,
    rel.subjectLabel = row.subject,
    rel.objectLabel = row.object,
    rel.description = row.description,
    rel.cardinalityNote = 'Reference architecture guidance';

MATCH (cmc:CMCPackage {cmcPackageId: 'CMC-AZD-CDC-10MG-001'})
MATCH (rel:RelationshipDefinition)
MERGE (cmc)-[:REFERENCES_RELATIONSHIP_DEFINITION]->(rel);

// Anchor reference catalog nodes that are useful for architecture discussion
// but may not be used by the current representative CDE subset.
MATCH (cmc:CMCPackage {cmcPackageId: 'CMC-AZD-CDC-10MG-001'})
WITH cmc
MATCH (standard:DataStandard)
MERGE (cmc)-[:REFERENCES_STANDARD]->(standard);

MATCH (cmc:CMCPackage {cmcPackageId: 'CMC-AZD-CDC-10MG-001'})
WITH cmc
MATCH (section:RegulatorySection)
MERGE (cmc)-[:REFERENCES_CMC_SECTION]->(section);

MATCH (cmc:CMCPackage {cmcPackageId: 'CMC-AZD-CDC-10MG-001'})
WITH cmc
MATCH (owner:DataOwner)
MERGE (cmc)-[:HAS_DATA_OWNER]->(owner);

MATCH (cmc:CMCPackage {cmcPackageId: 'CMC-AZD-CDC-10MG-001'})
WITH cmc
MATCH (unit:UnitOfMeasure)
MERGE (cmc)-[:REFERENCES_UNIT]->(unit);
