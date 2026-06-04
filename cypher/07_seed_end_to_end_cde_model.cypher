// End-to-end CDC conceptual data model and CDE registry extension.
// Scope: crystallisation to semi-continuous powder coated tablet collection.

// ---------------------------------------------------------------------------
// Standards, regulatory sections, source systems, owners, stewards, DQ rules
// ---------------------------------------------------------------------------
UNWIND [
  {id: 'STD-ICH-Q13', name: 'ICH Q13', type: 'ICH guideline', description: 'Continuous manufacturing of drug substances and drug products'},
  {id: 'STD-ICH-Q8', name: 'ICH Q8', type: 'ICH guideline', description: 'Pharmaceutical development'},
  {id: 'STD-ICH-Q9', name: 'ICH Q9', type: 'ICH guideline', description: 'Quality risk management'},
  {id: 'STD-ICH-Q10', name: 'ICH Q10', type: 'ICH guideline', description: 'Pharmaceutical quality system'},
  {id: 'STD-ICH-Q11', name: 'ICH Q11', type: 'ICH guideline', description: 'Development and manufacture of drug substances'},
  {id: 'STD-ICH-Q12', name: 'ICH Q12', type: 'ICH guideline', description: 'Lifecycle management and regulatory change management'},
  {id: 'STD-ICH-Q14', name: 'ICH Q14', type: 'ICH guideline', description: 'Analytical procedure development'},
  {id: 'STD-CTD-M3', name: 'CTD Module 3 / ICH M4Q', type: 'Regulatory dossier structure', description: 'Quality / CMC module for drug substance and drug product'},
  {id: 'STD-ISO-11179', name: 'ISO/IEC 11179', type: 'Metadata registry standard', description: 'Data element definitions, naming, identification, classification, and mapping'},
  {id: 'STD-ISO-14644', name: 'ISO 14644', type: 'Cleanroom standard', description: 'Cleanrooms and associated controlled environments'},
  {id: 'STD-ISO-22400', name: 'ISO 22400', type: 'Manufacturing KPI standard', description: 'KPIs for manufacturing operations management'},
  {id: 'STD-ISA-95', name: 'ISA-95 / IEC 62264', type: 'Manufacturing integration standard', description: 'Enterprise-control system integration and equipment hierarchy'}
] AS row
MERGE (standard:DataStandard {standardId: row.id})
SET standard.name = row.name,
    standard.standardType = row.type,
    standard.description = row.description,
    standard.status = 'Reference mapping';

UNWIND [
  {id: 'CTD-3.2.S.2.2', name: '3.2.S.2.2 Description of Manufacturing Process and Process Controls', scope: 'Drug substance'},
  {id: 'CTD-3.2.S.2.3', name: '3.2.S.2.3 Control of Materials', scope: 'Drug substance'},
  {id: 'CTD-3.2.S.2.4', name: '3.2.S.2.4 Controls of Critical Steps and Intermediates', scope: 'Drug substance'},
  {id: 'CTD-3.2.S.3.2', name: '3.2.S.3.2 Impurities', scope: 'Drug substance'},
  {id: 'CTD-3.2.S.4', name: '3.2.S.4 Control of Drug Substance', scope: 'Drug substance'},
  {id: 'CTD-3.2.P.2', name: '3.2.P.2 Pharmaceutical Development', scope: 'Drug product'},
  {id: 'CTD-3.2.P.3.3', name: '3.2.P.3.3 Description of Manufacturing Process and Process Controls', scope: 'Drug product'},
  {id: 'CTD-3.2.P.3.4', name: '3.2.P.3.4 Controls of Critical Steps and Intermediates', scope: 'Drug product'},
  {id: 'CTD-3.2.P.5', name: '3.2.P.5 Control of Drug Product', scope: 'Drug product'},
  {id: 'CTD-3.2.P.8', name: '3.2.P.8 Stability', scope: 'Drug product'}
] AS row
MERGE (section:RegulatorySection {sectionId: row.id})
SET section.name = row.name,
    section.scope = row.scope,
    section.framework = 'CTD Module 3 / CMC';

UNWIND [
  {id: 'SRC-DS-DCS', name: 'Drug substance DCS / PLC', type: 'Control system', isa95: 'Level 2'},
  {id: 'SRC-DP-DCS', name: 'Drug product CDC DCS', type: 'Control system', isa95: 'Level 2'},
  {id: 'SRC-HISTORIAN', name: 'Process historian', type: 'Time-series historian', isa95: 'Level 2/3'},
  {id: 'SRC-PAT', name: 'PAT platform', type: 'PAT / model system', isa95: 'Level 2/3'},
  {id: 'SRC-LIMS', name: 'LIMS', type: 'Laboratory information management', isa95: 'Level 3'},
  {id: 'SRC-MES-EBR', name: 'MES / electronic batch record', type: 'Manufacturing execution', isa95: 'Level 3'},
  {id: 'SRC-QMS', name: 'QMS', type: 'Quality management system', isa95: 'Level 4'},
  {id: 'SRC-ERP', name: 'ERP / material management', type: 'Enterprise resource planning', isa95: 'Level 4'},
  {id: 'SRC-EMS', name: 'Environmental monitoring system', type: 'Environmental monitoring', isa95: 'Level 2/3'}
] AS row
MERGE (source:DataSourceSystem {sourceSystemId: row.id})
SET source.name = row.name,
    source.systemType = row.type,
    source.isa95Level = row.isa95;

UNWIND [
  {id: 'OWNER-MSAT', name: 'MSAT', function: 'Manufacturing science and technology'},
  {id: 'OWNER-MFG', name: 'Manufacturing Operations', function: 'Manufacturing execution'},
  {id: 'OWNER-QC', name: 'Quality Control', function: 'Analytical testing'},
  {id: 'OWNER-QA', name: 'Quality Assurance', function: 'Quality disposition and QMS'},
  {id: 'OWNER-REG-CMC', name: 'Regulatory CMC', function: 'CMC filing and commitments'},
  {id: 'OWNER-DATA-GOV', name: 'Data Governance', function: 'CDE standards and metadata'}
] AS row
MERGE (owner:DataOwner {ownerId: row.id})
SET owner.name = row.name,
    owner.businessFunction = row.function;

UNWIND [
  {id: 'STEWARD-DS', name: 'Drug substance data steward', area: 'Crystallisation, isolation, drying, milling'},
  {id: 'STEWARD-DP', name: 'Drug product data steward', area: 'CDC, compression, coating'},
  {id: 'STEWARD-QC', name: 'QC data steward', area: 'Analytical methods and results'},
  {id: 'STEWARD-QA', name: 'QA data steward', area: 'Batch record, deviation, audit trail'},
  {id: 'STEWARD-CMC', name: 'CMC data steward', area: 'Regulatory CMC mapping'}
] AS row
MERGE (steward:DataSteward {stewardId: row.id})
SET steward.name = row.name,
    steward.area = row.area;

UNWIND [
  {id: 'DQR-COMPLETE', name: 'Completeness rule', dimension: 'Completeness', rule: 'Required CDE must be present for the applicable unit operation and run segment.'},
  {id: 'DQR-RANGE', name: 'Range conformance rule', dimension: 'Validity', rule: 'Numeric CDE must conform to approved engineering, process, or specification limits.'},
  {id: 'DQR-UNIT', name: 'Unit of measure rule', dimension: 'Consistency', rule: 'CDE must use the controlled unit of measure or approved conversion.'},
  {id: 'DQR-TIMESTAMP', name: 'Timestamp integrity rule', dimension: 'Timeliness', rule: 'Time-series CDE must have synchronized timestamp and source-system context.'},
  {id: 'DQR-LOT-LINK', name: 'Lot genealogy rule', dimension: 'Traceability', rule: 'Material CDE must link to a material lot, material master, and supplier where applicable.'},
  {id: 'DQR-ALCOA', name: 'ALCOA+ review rule', dimension: 'Data integrity', rule: 'GxP-relevant CDE must be attributable, legible, contemporaneous, original, accurate, complete, consistent, enduring, and available in validated implementations.'}
] AS row
MERGE (rule:DataQualityRule {ruleId: row.id})
SET rule.name = row.name,
    rule.dimension = row.dimension,
    rule.ruleText = row.rule,
    rule.status = 'Reference rule';

// ---------------------------------------------------------------------------
// Process segments and unit operations
// ---------------------------------------------------------------------------
UNWIND [
  {id: 'SEG-DS-FORMATION', name: 'Drug substance formation and isolation', order: 1},
  {id: 'SEG-API-PARTICLE-ENGINEERING', name: 'API particle engineering', order: 2},
  {id: 'SEG-DP-CDC', name: 'Drug product continuous direct compression', order: 3},
  {id: 'SEG-DP-POWDER-COATING', name: 'Semi-continuous powder coating', order: 4},
  {id: 'SEG-QA-CMC-EVIDENCE', name: 'QA, CMC, and regulatory evidence', order: 5}
] AS row
MERGE (segment:ProcessSegment {processSegmentId: row.id})
SET segment.name = row.name,
    segment.segmentOrder = row.order,
    segment.processMode = 'End-to-end integrated manufacturing demo';

UNWIND [
  {id: 'UO-001-CRYSTALLISATION', name: 'Crystallisation', order: 1, segmentId: 'SEG-DS-FORMATION', type: 'Drug substance unit operation', mode: 'Semi-continuous'},
  {id: 'UO-002-ISOLATION-WASH', name: 'Isolation, filtration, and washing', order: 2, segmentId: 'SEG-DS-FORMATION', type: 'Drug substance unit operation', mode: 'Semi-continuous'},
  {id: 'UO-003-DRYING', name: 'Drying', order: 3, segmentId: 'SEG-DS-FORMATION', type: 'Drug substance unit operation', mode: 'Semi-continuous'},
  {id: 'UO-004-MILLING-SIEVING', name: 'Milling, micronisation, and sieving', order: 4, segmentId: 'SEG-API-PARTICLE-ENGINEERING', type: 'Particle engineering', mode: 'Batch or semi-continuous'},
  {id: 'UO-005-API-HANDLING', name: 'API intermediate handling', order: 5, segmentId: 'SEG-API-PARTICLE-ENGINEERING', type: 'Material handling', mode: 'Controlled hold'},
  {id: 'UO-006-FEEDING', name: 'API and excipient feeding', order: 6, segmentId: 'SEG-DP-CDC', type: 'CDC unit operation', mode: 'Continuous'},
  {id: 'UO-007-BLENDING', name: 'Continuous blending', order: 7, segmentId: 'SEG-DP-CDC', type: 'CDC unit operation', mode: 'Continuous'},
  {id: 'UO-008-LUBRICATION', name: 'Lubricant addition', order: 8, segmentId: 'SEG-DP-CDC', type: 'CDC unit operation', mode: 'Continuous'},
  {id: 'UO-009-COMPRESSION', name: 'Tablet compression and weight control', order: 9, segmentId: 'SEG-DP-CDC', type: 'CDC unit operation', mode: 'Continuous'},
  {id: 'UO-010-POWDER-COATING', name: 'Semi-continuous powder coating', order: 10, segmentId: 'SEG-DP-POWDER-COATING', type: 'Drug product finishing', mode: 'Semi-continuous'},
  {id: 'UO-011-COATED-COLLECTION', name: 'Powder coated tablet collection', order: 11, segmentId: 'SEG-DP-POWDER-COATING', type: 'Finished product collection', mode: 'Semi-continuous'},
  {id: 'UO-012-QA-CMC-REVIEW', name: 'QA, CMC, and regulatory evidence review', order: 12, segmentId: 'SEG-QA-CMC-EVIDENCE', type: 'Quality and regulatory review', mode: 'Review'}
] AS row
MATCH (segment:ProcessSegment {processSegmentId: row.segmentId})
MERGE (uo:UnitOperation {unitOperationId: row.id})
SET uo.name = row.name,
    uo.operationOrder = row.order,
    uo.operationType = row.type,
    uo.processMode = row.mode
MERGE (segment)-[:CONTAINS_OPERATION]->(uo);

UNWIND [
  ['UO-001-CRYSTALLISATION', 'UO-002-ISOLATION-WASH'],
  ['UO-002-ISOLATION-WASH', 'UO-003-DRYING'],
  ['UO-003-DRYING', 'UO-004-MILLING-SIEVING'],
  ['UO-004-MILLING-SIEVING', 'UO-005-API-HANDLING'],
  ['UO-005-API-HANDLING', 'UO-006-FEEDING'],
  ['UO-006-FEEDING', 'UO-007-BLENDING'],
  ['UO-007-BLENDING', 'UO-008-LUBRICATION'],
  ['UO-008-LUBRICATION', 'UO-009-COMPRESSION'],
  ['UO-009-COMPRESSION', 'UO-010-POWDER-COATING'],
  ['UO-010-POWDER-COATING', 'UO-011-COATED-COLLECTION'],
  ['UO-011-COATED-COLLECTION', 'UO-012-QA-CMC-REVIEW']
] AS pair
MATCH (from:UnitOperation {unitOperationId: pair[0]})
MATCH (to:UnitOperation {unitOperationId: pair[1]})
MERGE (from)-[:NEXT_OPERATION]->(to);

UNWIND [
  {id: 'IP-CRYSTALLINE-SLURRY', name: 'Crystalline API slurry', operationId: 'UO-001-CRYSTALLISATION', state: 'Slurry'},
  {id: 'IP-WET-CAKE', name: 'Washed API wet cake', operationId: 'UO-002-ISOLATION-WASH', state: 'Wet cake'},
  {id: 'IP-DRIED-API', name: 'Dried API intermediate', operationId: 'UO-003-DRYING', state: 'Dry powder'},
  {id: 'IP-MILLED-API', name: 'Milled API intermediate', operationId: 'UO-004-MILLING-SIEVING', state: 'Engineered powder'},
  {id: 'IP-CONTINUOUS-BLEND', name: 'Continuous lubricated blend', operationId: 'UO-008-LUBRICATION', state: 'Final blend'},
  {id: 'IP-CORE-TABLET', name: 'Core tablet', operationId: 'UO-009-COMPRESSION', state: 'Compressed tablet'},
  {id: 'IP-POWDER-COATED-TABLET', name: 'Powder coated tablet', operationId: 'UO-011-COATED-COLLECTION', state: 'Coated tablet'}
] AS row
MATCH (uo:UnitOperation {unitOperationId: row.operationId})
MERGE (ip:IntermediateProduct {intermediateProductId: row.id})
SET ip.name = row.name,
    ip.materialState = row.state,
    ip.status = 'Conceptual material state'
MERGE (uo)-[:PRODUCES]->(ip);

UNWIND [
  {id: 'MT-SOLUTION-TO-SLURRY', name: 'Solution to crystalline slurry', fromState: 'Solution', toState: 'Crystalline slurry', operationId: 'UO-001-CRYSTALLISATION'},
  {id: 'MT-SLURRY-TO-WET-CAKE', name: 'Slurry to washed wet cake', fromState: 'Crystalline slurry', toState: 'Wet cake', operationId: 'UO-002-ISOLATION-WASH'},
  {id: 'MT-WET-CAKE-TO-DRIED-API', name: 'Wet cake to dried API', fromState: 'Wet cake', toState: 'Dried API', operationId: 'UO-003-DRYING'},
  {id: 'MT-DRIED-TO-MILLED-API', name: 'Dried API to milled API', fromState: 'Dried API', toState: 'Milled API', operationId: 'UO-004-MILLING-SIEVING'},
  {id: 'MT-API-EXCIPIENT-TO-BLEND', name: 'API and excipients to final blend', fromState: 'Powders', toState: 'Lubricated blend', operationId: 'UO-008-LUBRICATION'},
  {id: 'MT-BLEND-TO-CORE-TABLET', name: 'Blend to core tablet', fromState: 'Lubricated blend', toState: 'Core tablet', operationId: 'UO-009-COMPRESSION'},
  {id: 'MT-CORE-TO-COATED-TABLET', name: 'Core tablet to powder coated tablet', fromState: 'Core tablet', toState: 'Powder coated tablet', operationId: 'UO-010-POWDER-COATING'}
] AS row
MATCH (uo:UnitOperation {unitOperationId: row.operationId})
MERGE (mt:MaterialTransformation {transformationId: row.id})
SET mt.name = row.name,
    mt.fromState = row.fromState,
    mt.toState = row.toState
MERGE (uo)-[:HAS_TRANSFORMATION]->(mt);

// ---------------------------------------------------------------------------
// Representative CDE catalog with governance and standards mappings
// ---------------------------------------------------------------------------
UNWIND [
  {id: 'CDE-CRYST-SOLVENT-COMP', name: 'Solvent composition', domain: 'CPP/CMA', criticality: 'Critical', uo: 'UO-001-CRYSTALLISATION', source: 'SRC-LIMS', owner: 'OWNER-MSAT', steward: 'STEWARD-DS', rules: ['DQR-COMPLETE','DQR-UNIT','DQR-ALCOA'], standards: ['STD-ICH-Q11','STD-ICH-Q13','STD-CTD-M3','STD-ISO-11179'], sections: ['CTD-3.2.S.2.2','CTD-3.2.S.2.3']},
  {id: 'CDE-CRYST-SUPERSAT', name: 'Supersaturation', domain: 'CPP', criticality: 'Critical', uo: 'UO-001-CRYSTALLISATION', source: 'SRC-DS-DCS', owner: 'OWNER-MSAT', steward: 'STEWARD-DS', rules: ['DQR-COMPLETE','DQR-RANGE','DQR-TIMESTAMP'], standards: ['STD-ICH-Q11','STD-ICH-Q13','STD-ISA-95'], sections: ['CTD-3.2.S.2.2','CTD-3.2.S.2.4']},
  {id: 'CDE-CRYST-SEED-LOT', name: 'Seed lot ID', domain: 'Genealogy/CMA', criticality: 'Critical', uo: 'UO-001-CRYSTALLISATION', source: 'SRC-ERP', owner: 'OWNER-MFG', steward: 'STEWARD-DS', rules: ['DQR-COMPLETE','DQR-LOT-LINK','DQR-ALCOA'], standards: ['STD-ICH-Q11','STD-CTD-M3','STD-ISO-11179'], sections: ['CTD-3.2.S.2.3','CTD-3.2.S.2.4']},
  {id: 'CDE-CRYST-PSD', name: 'Crystal size distribution', domain: 'CQA/CMA', criticality: 'Critical', uo: 'UO-001-CRYSTALLISATION', source: 'SRC-LIMS', owner: 'OWNER-QC', steward: 'STEWARD-QC', rules: ['DQR-COMPLETE','DQR-UNIT','DQR-ALCOA'], standards: ['STD-ICH-Q11','STD-ICH-Q14','STD-CTD-M3'], sections: ['CTD-3.2.S.4','CTD-3.2.S.2.4']},
  {id: 'CDE-CRYST-POLYMORPH', name: 'Polymorphic form', domain: 'CQA', criticality: 'Critical', uo: 'UO-001-CRYSTALLISATION', source: 'SRC-LIMS', owner: 'OWNER-QC', steward: 'STEWARD-QC', rules: ['DQR-COMPLETE','DQR-ALCOA'], standards: ['STD-ICH-Q11','STD-ICH-Q14','STD-CTD-M3'], sections: ['CTD-3.2.S.4']},
  {id: 'CDE-ISO-WASH-VOLUME', name: 'Wash solvent volume', domain: 'CPP', criticality: 'Critical', uo: 'UO-002-ISOLATION-WASH', source: 'SRC-DS-DCS', owner: 'OWNER-MFG', steward: 'STEWARD-DS', rules: ['DQR-COMPLETE','DQR-RANGE','DQR-UNIT'], standards: ['STD-ICH-Q11','STD-ICH-Q13','STD-CTD-M3'], sections: ['CTD-3.2.S.2.2','CTD-3.2.S.2.4']},
  {id: 'CDE-ISO-WET-CAKE-MASS', name: 'Wet cake mass', domain: 'Genealogy', criticality: 'Critical', uo: 'UO-002-ISOLATION-WASH', source: 'SRC-MES-EBR', owner: 'OWNER-MFG', steward: 'STEWARD-DS', rules: ['DQR-COMPLETE','DQR-ALCOA'], standards: ['STD-ICH-Q13','STD-CTD-M3','STD-ISO-22400'], sections: ['CTD-3.2.S.2.2']},
  {id: 'CDE-DRY-LOD-ENDPOINT', name: 'Loss on drying endpoint', domain: 'CQA/IPC', criticality: 'Critical', uo: 'UO-003-DRYING', source: 'SRC-LIMS', owner: 'OWNER-QC', steward: 'STEWARD-QC', rules: ['DQR-COMPLETE','DQR-RANGE','DQR-ALCOA'], standards: ['STD-ICH-Q11','STD-ICH-Q14','STD-CTD-M3'], sections: ['CTD-3.2.S.2.4','CTD-3.2.S.4']},
  {id: 'CDE-DRY-RESIDUAL-SOLVENT', name: 'Residual solvent result', domain: 'CQA', criticality: 'Critical', uo: 'UO-003-DRYING', source: 'SRC-LIMS', owner: 'OWNER-QC', steward: 'STEWARD-QC', rules: ['DQR-COMPLETE','DQR-RANGE','DQR-ALCOA'], standards: ['STD-ICH-Q11','STD-ICH-Q14','STD-CTD-M3'], sections: ['CTD-3.2.S.4']},
  {id: 'CDE-MILL-FEED-RATE', name: 'Feed rate to mill', domain: 'CPP', criticality: 'Critical', uo: 'UO-004-MILLING-SIEVING', source: 'SRC-HISTORIAN', owner: 'OWNER-MSAT', steward: 'STEWARD-DS', rules: ['DQR-COMPLETE','DQR-RANGE','DQR-TIMESTAMP'], standards: ['STD-ICH-Q11','STD-ICH-Q13','STD-ISA-95'], sections: ['CTD-3.2.S.2.2','CTD-3.2.S.2.4']},
  {id: 'CDE-MILL-API-PSD', name: 'Milled API particle size distribution', domain: 'CMA', criticality: 'Critical', uo: 'UO-004-MILLING-SIEVING', source: 'SRC-LIMS', owner: 'OWNER-QC', steward: 'STEWARD-QC', rules: ['DQR-COMPLETE','DQR-UNIT','DQR-ALCOA'], standards: ['STD-ICH-Q11','STD-ICH-Q14','STD-CTD-M3'], sections: ['CTD-3.2.S.4','CTD-3.2.P.2']},
  {id: 'CDE-API-HOLD-TIME', name: 'API intermediate hold time', domain: 'Genealogy/QMS', criticality: 'Critical', uo: 'UO-005-API-HANDLING', source: 'SRC-MES-EBR', owner: 'OWNER-QA', steward: 'STEWARD-QA', rules: ['DQR-COMPLETE','DQR-TIMESTAMP','DQR-ALCOA'], standards: ['STD-ICH-Q10','STD-ICH-Q12','STD-CTD-M3'], sections: ['CTD-3.2.S.2.4']},
  {id: 'CDE-CDC-API-FEED-RATE', name: 'API feed rate', domain: 'CPP', criticality: 'Critical', uo: 'UO-006-FEEDING', source: 'SRC-HISTORIAN', owner: 'OWNER-MSAT', steward: 'STEWARD-DP', rules: ['DQR-COMPLETE','DQR-RANGE','DQR-TIMESTAMP'], standards: ['STD-ICH-Q13','STD-ISA-95','STD-CTD-M3'], sections: ['CTD-3.2.P.3.3','CTD-3.2.P.3.4']},
  {id: 'CDE-CDC-BLEND-NIR', name: 'Inline NIR blend uniformity', domain: 'CQA/PAT', criticality: 'Critical', uo: 'UO-007-BLENDING', source: 'SRC-PAT', owner: 'OWNER-QC', steward: 'STEWARD-QC', rules: ['DQR-COMPLETE','DQR-RANGE','DQR-TIMESTAMP','DQR-ALCOA'], standards: ['STD-ICH-Q13','STD-ICH-Q14','STD-CTD-M3'], sections: ['CTD-3.2.P.3.4','CTD-3.2.P.5']},
  {id: 'CDE-CDC-LUB-FEED-RATE', name: 'Lubricant feed rate', domain: 'CPP', criticality: 'Critical', uo: 'UO-008-LUBRICATION', source: 'SRC-HISTORIAN', owner: 'OWNER-MSAT', steward: 'STEWARD-DP', rules: ['DQR-COMPLETE','DQR-RANGE','DQR-TIMESTAMP'], standards: ['STD-ICH-Q13','STD-CTD-M3'], sections: ['CTD-3.2.P.3.3','CTD-3.2.P.3.4']},
  {id: 'CDE-CDC-COMPRESSION-FORCE', name: 'Compression force', domain: 'CPP', criticality: 'Critical', uo: 'UO-009-COMPRESSION', source: 'SRC-HISTORIAN', owner: 'OWNER-MSAT', steward: 'STEWARD-DP', rules: ['DQR-COMPLETE','DQR-RANGE','DQR-TIMESTAMP'], standards: ['STD-ICH-Q13','STD-ISA-95','STD-CTD-M3'], sections: ['CTD-3.2.P.3.4']},
  {id: 'CDE-CDC-TABLET-WEIGHT', name: 'Tablet weight', domain: 'CQA/IPC', criticality: 'Critical', uo: 'UO-009-COMPRESSION', source: 'SRC-HISTORIAN', owner: 'OWNER-QC', steward: 'STEWARD-DP', rules: ['DQR-COMPLETE','DQR-RANGE','DQR-TIMESTAMP','DQR-ALCOA'], standards: ['STD-ICH-Q13','STD-CTD-M3'], sections: ['CTD-3.2.P.3.4','CTD-3.2.P.5']},
  {id: 'CDE-COAT-POWDER-LOT', name: 'Coating powder lot ID', domain: 'Genealogy', criticality: 'Critical', uo: 'UO-010-POWDER-COATING', source: 'SRC-ERP', owner: 'OWNER-MFG', steward: 'STEWARD-DP', rules: ['DQR-COMPLETE','DQR-LOT-LINK','DQR-ALCOA'], standards: ['STD-ICH-Q13','STD-CTD-M3','STD-ISO-11179'], sections: ['CTD-3.2.P.3.3','CTD-3.2.P.3.4']},
  {id: 'CDE-COAT-FEED-RATE', name: 'Coating powder feed rate', domain: 'CPP', criticality: 'Critical', uo: 'UO-010-POWDER-COATING', source: 'SRC-DP-DCS', owner: 'OWNER-MSAT', steward: 'STEWARD-DP', rules: ['DQR-COMPLETE','DQR-RANGE','DQR-TIMESTAMP'], standards: ['STD-ICH-Q13','STD-ISA-95','STD-CTD-M3'], sections: ['CTD-3.2.P.3.3','CTD-3.2.P.3.4']},
  {id: 'CDE-COAT-RH', name: 'Coating room relative humidity', domain: 'CPP', criticality: 'Critical', uo: 'UO-010-POWDER-COATING', source: 'SRC-EMS', owner: 'OWNER-MFG', steward: 'STEWARD-DP', rules: ['DQR-COMPLETE','DQR-RANGE','DQR-TIMESTAMP'], standards: ['STD-ISO-14644','STD-ICH-Q13','STD-CTD-M3'], sections: ['CTD-3.2.P.3.4']},
  {id: 'CDE-COAT-WEIGHT-GAIN', name: 'Coating weight gain', domain: 'CQA/IPC', criticality: 'Critical', uo: 'UO-010-POWDER-COATING', source: 'SRC-MES-EBR', owner: 'OWNER-QC', steward: 'STEWARD-DP', rules: ['DQR-COMPLETE','DQR-RANGE','DQR-ALCOA'], standards: ['STD-ICH-Q13','STD-CTD-M3'], sections: ['CTD-3.2.P.3.4','CTD-3.2.P.5']},
  {id: 'CDE-COAT-UNIFORMITY', name: 'Coating uniformity', domain: 'CQA', criticality: 'Critical', uo: 'UO-010-POWDER-COATING', source: 'SRC-PAT', owner: 'OWNER-QC', steward: 'STEWARD-QC', rules: ['DQR-COMPLETE','DQR-RANGE','DQR-ALCOA'], standards: ['STD-ICH-Q14','STD-ICH-Q13','STD-CTD-M3'], sections: ['CTD-3.2.P.5']},
  {id: 'CDE-COATED-CONTAINER-ID', name: 'Powder coated tablet container ID', domain: 'Genealogy', criticality: 'Critical', uo: 'UO-011-COATED-COLLECTION', source: 'SRC-MES-EBR', owner: 'OWNER-MFG', steward: 'STEWARD-DP', rules: ['DQR-COMPLETE','DQR-LOT-LINK','DQR-ALCOA'], standards: ['STD-ICH-Q13','STD-CTD-M3','STD-ISO-11179'], sections: ['CTD-3.2.P.3.3']},
  {id: 'CDE-QA-DISPOSITION', name: 'QA disposition decision', domain: 'Disposition', criticality: 'Critical', uo: 'UO-012-QA-CMC-REVIEW', source: 'SRC-QMS', owner: 'OWNER-QA', steward: 'STEWARD-QA', rules: ['DQR-COMPLETE','DQR-ALCOA'], standards: ['STD-ICH-Q10','STD-ICH-Q12','STD-CTD-M3'], sections: ['CTD-3.2.P.3.4','CTD-3.2.P.5']},
  {id: 'CDE-CMC-SECTION-MAPPING', name: 'CMC section mapping', domain: 'Regulatory metadata', criticality: 'Important', uo: 'UO-012-QA-CMC-REVIEW', source: 'SRC-QMS', owner: 'OWNER-REG-CMC', steward: 'STEWARD-CMC', rules: ['DQR-COMPLETE','DQR-ALCOA'], standards: ['STD-CTD-M3','STD-ISO-11179'], sections: ['CTD-3.2.S.2.2','CTD-3.2.P.3.3']}
] AS row
MATCH (uo:UnitOperation {unitOperationId: row.uo})
MATCH (source:DataSourceSystem {sourceSystemId: row.source})
MATCH (owner:DataOwner {ownerId: row.owner})
MATCH (steward:DataSteward {stewardId: row.steward})
MERGE (cde:CriticalDataElement {cdeId: row.id})
SET cde.name = row.name,
    cde.domain = row.domain,
    cde.criticality = row.criticality,
    cde.definition = row.name + ' captured or governed as a critical data element for the end-to-end CDC conceptual model.',
    cde.status = 'Proposed reference CDE'
MERGE (cde)-[:OBSERVED_AT]->(uo)
MERGE (cde)-[:SOURCED_FROM]->(source)
MERGE (cde)-[:HAS_OWNER]->(owner)
MERGE (cde)-[:HAS_STEWARD]->(steward)
WITH row, cde
UNWIND row.rules AS ruleId
MATCH (rule:DataQualityRule {ruleId: ruleId})
MERGE (cde)-[:HAS_DATA_QUALITY_RULE]->(rule)
WITH row, cde
UNWIND row.standards AS standardId
MATCH (standard:DataStandard {standardId: standardId})
MERGE (cde)-[:MAPS_TO_STANDARD]->(standard)
WITH row, cde
UNWIND row.sections AS sectionId
MATCH (section:RegulatorySection {sectionId: sectionId})
MERGE (cde)-[:SUPPORTS_CMC_SECTION]->(section);

// Connect selected CDEs to existing graph concepts where a direct demo concept exists.
UNWIND [
  {cdeId: 'CDE-CDC-API-FEED-RATE', conceptLabel: 'CPP', conceptId: 'CPP-API-FEED-RATE'},
  {cdeId: 'CDE-CDC-BLEND-NIR', conceptLabel: 'CQA', conceptId: 'CQA-BLEND-UNIFORMITY'},
  {cdeId: 'CDE-CDC-LUB-FEED-RATE', conceptLabel: 'CPP', conceptId: 'CPP-LUB-FEED-RATE'},
  {cdeId: 'CDE-CDC-COMPRESSION-FORCE', conceptLabel: 'CPP', conceptId: 'CPP-COMPRESSION-FORCE'},
  {cdeId: 'CDE-CDC-TABLET-WEIGHT', conceptLabel: 'CQA', conceptId: 'CQA-TABLET-WEIGHT'},
  {cdeId: 'CDE-MILL-API-PSD', conceptLabel: 'CriticalMaterialAttribute', conceptId: 'CMA-API-PSD'},
  {cdeId: 'CDE-QA-DISPOSITION', conceptLabel: 'QAReleaseDecision', conceptId: 'QA-REL-NCLCDC10-260601'}
] AS row
MATCH (cde:CriticalDataElement {cdeId: row.cdeId})
CALL {
  WITH row
  OPTIONAL MATCH (cpp:CPP {cppId: row.conceptId})
  WHERE row.conceptLabel = 'CPP'
  RETURN cpp AS concept
  UNION
  WITH row
  OPTIONAL MATCH (cqa:CQA {cqaId: row.conceptId})
  WHERE row.conceptLabel = 'CQA'
  RETURN cqa AS concept
  UNION
  WITH row
  OPTIONAL MATCH (cma:CriticalMaterialAttribute {cmaId: row.conceptId})
  WHERE row.conceptLabel = 'CriticalMaterialAttribute'
  RETURN cma AS concept
  UNION
  WITH row
  OPTIONAL MATCH (decision:QAReleaseDecision {decisionId: row.conceptId})
  WHERE row.conceptLabel = 'QAReleaseDecision'
  RETURN decision AS concept
}
WITH cde, concept
WHERE concept IS NOT NULL
MERGE (cde)-[:DESCRIBES]->(concept);

// Map CDC unit operations to current CDC recipe process steps where applicable.
UNWIND [
  {uoId: 'UO-006-FEEDING', stepId: 'STEP-001-API-FEED'},
  {uoId: 'UO-006-FEEDING', stepId: 'STEP-002-EXC-FEED'},
  {uoId: 'UO-007-BLENDING', stepId: 'STEP-003-CONT-BLEND'},
  {uoId: 'UO-008-LUBRICATION', stepId: 'STEP-004-LUB-ADD'},
  {uoId: 'UO-009-COMPRESSION', stepId: 'STEP-005-COMPRESS'},
  {uoId: 'UO-009-COMPRESSION', stepId: 'STEP-006-WEIGHT-CTRL'},
  {uoId: 'UO-011-COATED-COLLECTION', stepId: 'STEP-007-COLLECT'}
] AS row
MATCH (uo:UnitOperation {unitOperationId: row.uoId})
MATCH (step:ProcessStep {stepId: row.stepId})
MERGE (uo)-[:ALIGNS_TO_PROCESS_STEP]->(step);

// Control points and sampling points.
UNWIND [
  {id: 'CP-CRYST-ENDPOINT', name: 'Crystallisation endpoint control', uoId: 'UO-001-CRYSTALLISATION'},
  {id: 'CP-DRY-ENDPOINT', name: 'Drying endpoint control', uoId: 'UO-003-DRYING'},
  {id: 'CP-NIR-BLEND', name: 'NIR blend uniformity control point', uoId: 'UO-007-BLENDING'},
  {id: 'CP-TABLET-WEIGHT', name: 'Tablet weight control point', uoId: 'UO-009-COMPRESSION'},
  {id: 'CP-COATING-WEIGHT', name: 'Coating weight gain control point', uoId: 'UO-010-POWDER-COATING'}
] AS row
MATCH (uo:UnitOperation {unitOperationId: row.uoId})
MERGE (cp:ControlPoint {controlPointId: row.id})
SET cp.name = row.name,
    cp.status = 'Conceptual control point'
MERGE (uo)-[:HAS_CONTROL_POINT]->(cp);

UNWIND [
  {id: 'SP-CRYST-SLURRY', name: 'Crystallisation slurry sample', uoId: 'UO-001-CRYSTALLISATION'},
  {id: 'SP-DRIED-API', name: 'Dried API sample', uoId: 'UO-003-DRYING'},
  {id: 'SP-MILLED-API', name: 'Milled API sample', uoId: 'UO-004-MILLING-SIEVING'},
  {id: 'SP-BLEND-PAT', name: 'Inline blend PAT point', uoId: 'UO-007-BLENDING'},
  {id: 'SP-CORE-TABLET', name: 'Core tablet IPC sample', uoId: 'UO-009-COMPRESSION'},
  {id: 'SP-COATED-TABLET', name: 'Coated tablet IPC sample', uoId: 'UO-010-POWDER-COATING'}
] AS row
MATCH (uo:UnitOperation {unitOperationId: row.uoId})
MERGE (sp:SamplingPoint {samplingPointId: row.id})
SET sp.name = row.name,
    sp.status = 'Conceptual sampling point'
MERGE (uo)-[:HAS_SAMPLING_POINT]->(sp);

// Standard mappings are explicit governance records for CDE-to-standard-to-CMC traceability.
MATCH (cde:CriticalDataElement)-[:MAPS_TO_STANDARD]->(standard:DataStandard)
MERGE (mapping:StandardMapping {mappingId: cde.cdeId + '-' + standard.standardId})
SET mapping.name = cde.name + ' to ' + standard.name,
    mapping.mappingType = 'CDE standards context',
    mapping.rationale = 'Reference mapping for end-to-end CDC CDE architecture discussion.'
MERGE (mapping)-[:MAPS_CDE]->(cde)
MERGE (mapping)-[:TO_STANDARD]->(standard);

MATCH (cde:CriticalDataElement)-[:SUPPORTS_CMC_SECTION]->(section:RegulatorySection)
MATCH (mapping:StandardMapping {mappingId: cde.cdeId + '-STD-CTD-M3'})
MERGE (mapping)-[:TO_REGULATORY_SECTION]->(section);

// Connect to the CMC package and control strategy already seeded by the CMC/QMS extension.
MATCH (cmc:CMCPackage {cmcPackageId: 'CMC-NCL-CDC-10MG-001'})
MATCH (cde:CriticalDataElement)
MERGE (cmc)-[:GOVERNS_CDE]->(cde);

MATCH (strategy:ControlStrategy {controlStrategyId: 'CS-NCL-CDC-10MG-001'})
MATCH (cde:CriticalDataElement)
WHERE cde.domain IN ['CPP', 'CQA', 'CQA/PAT', 'CQA/IPC', 'CPP/CMA', 'CMA']
MERGE (strategy)-[:USES_CDE]->(cde);
