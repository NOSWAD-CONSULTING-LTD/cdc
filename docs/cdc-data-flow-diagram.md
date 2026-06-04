# Reference Architecture for CDC Manufacturing Data Flow

This diagram shows how data flows into and through the CDC manufacturing knowledge graph. It separates source systems and governed master/reference data from manufacturing execution evidence, quality review, and CMC/regulatory use.

For printing or review on a single page, use the A4 landscape version:

[cdc-data-flow-a4.html](cdc-data-flow-a4.html)

```mermaid
flowchart LR
  %% Source and governance domains
  subgraph MD["Master And Reference Data"]
    P["Product<br/>NCL-CDC-Tablet-10mg"]
    F["Formulation<br/>API + excipients"]
    R["Recipe<br/>CDC process definition"]
    M["Material Master<br/>API, excipients, lubricant"]
    S["Supplier Master"]
    EQ["Equipment / Line / Room"]
    SEN["Sensor Master<br/>Historian and PAT tags"]
    CPP["CPP Definitions"]
    CQA["CQA + Specifications"]
  end

  subgraph EXEC["Manufacturing Execution"]
    ML["Material Lots<br/>received and released"]
    RUN["Manufacturing Run<br/>RUN-CDC-2026-06-01-001"]
    READ["Sensor Readings<br/>feeders, NIR, press, RH"]
    BR["Batch Record"]
  end

  subgraph QUAL["Quality Event And Disposition Flow"]
    ALM["Alarm<br/>NIR BU high"]
    DEV["Deviation<br/>impact assessment + CAPA text"]
    QA["QA Release Decision"]
    AUD["Audit Trail Events"]
  end

  subgraph CMC["CMC / QMS / Regulatory Evidence"]
    CMCP["CMC Package"]
    CS["Control Strategy"]
    RA["Risk Assessment"]
    AM["Analytical Methods"]
    STAB["Stability Study"]
    SOP["SOPs + Training"]
    QUALIF["Equipment Qualification"]
    CSV["Computer System Validation"]
    REG["Regulatory Filing"]
    VAL["Validation Evidence"]
  end

  %% Master/reference flow
  P -->|"HAS_FORMULATION"| F
  P -->|"HAS_RECIPE"| R
  F -->|"USES_MATERIAL"| M
  M -->|"QUALIFIED_SUPPLIER"| S
  R -->|"DEFINES_STEP"| EQ
  EQ -->|"HAS_SENSOR"| SEN
  SEN -->|"MEASURES"| CPP
  SEN -->|"MEASURES"| CQA
  CPP -->|"IMPACTS"| CQA

  %% Execution flow
  M -->|"INSTANCE_OF"| ML
  S -->|"SUPPLIED_BY"| ML
  R -->|"EXECUTED_BY"| RUN
  EQ -->|"USED_BY"| RUN
  ML -->|"CONSUMED_BY"| RUN
  SEN -->|"RECORDS"| READ
  READ -->|"DURING_RUN"| RUN
  RUN -->|"HAS_BATCH_RECORD"| BR

  %% Quality flow
  READ -->|"out-of-spec value triggers"| ALM
  ALM -->|"INVESTIGATED_BY"| DEV
  RUN -->|"HAS_DEVIATION"| DEV
  DEV -->|"reviewed in"| BR
  BR -->|"REVIEWS"| QA
  QA -->|"RELEASES"| RUN
  READ --> AUD
  ALM --> AUD
  DEV --> AUD
  QA --> AUD
  AUD -->|"documented in"| BR

  %% CMC/QMS/regulatory flow
  P -->|"HAS_CMC_PACKAGE"| CMCP
  REG -->|"SUBMITS"| CMCP
  CMCP -->|"INCLUDES"| CS
  CMCP -->|"INCLUDES"| RA
  CMCP -->|"INCLUDES"| AM
  CMCP -->|"INCLUDES"| STAB
  CMCP -->|"REFERENCES"| SOP
  CMCP -->|"INCLUDES"| QUALIF
  CMCP -->|"INCLUDES"| CSV
  CMCP -->|"INCLUDES"| VAL
  CS -->|"CONTROLS"| CPP
  CS -->|"PROTECTS"| CQA
  AM -->|"MEASURES"| CQA
  STAB -->|"MONITORS"| CQA
  SOP -->|"GOVERNS"| R
  SOP -->|"GOVERNS REVIEW OF"| BR
  QUALIF -->|"QUALIFIES"| EQ
  CSV -->|"VALIDATES DATA SOURCE"| SEN
  VAL -->|"SUPPORTS"| REG

  classDef master fill:#e8f2ff,stroke:#4f84bd,color:#1d2a32;
  classDef execution fill:#fff3df,stroke:#c28a35,color:#1d2a32;
  classDef quality fill:#f8eaf0,stroke:#b26078,color:#1d2a32;
  classDef cmc fill:#f0eef9,stroke:#7b69b1,color:#1d2a32;

  class P,F,R,M,S,EQ,SEN,CPP,CQA master;
  class ML,RUN,READ,BR execution;
  class ALM,DEV,QA,AUD quality;
  class CMCP,CS,RA,AM,STAB,SOP,QUALIF,CSV,REG,VAL cmc;
```

## Data Flow Summary

1. Master and reference data define the product, formulation, recipe, materials, suppliers, equipment, sensors, CPPs, CQAs, and specifications.
2. Manufacturing execution data records the run, consumed material lots, sensor readings, cleaning/calibration evidence, and batch record.
3. Quality event data links out-of-spec readings to alarms, deviations, impact assessments, audit trail events, and QA disposition.
4. CMC/QMS evidence connects the same process and quality evidence to control strategy, analytical methods, stability, validation, SOPs, training, qualification, CSV, and regulatory filing context.

## Key Architecture Point

The graph does not just store execution data. It connects each execution fact to the master data and governance context needed to interpret it. For example:

```text
SensorReading -> Sensor -> CPP/CQA -> Specification -> ControlStrategy -> CMCPackage -> RegulatoryFiling
```

and:

```text
ManufacturingRun -> MaterialLot -> Material -> CriticalMaterialAttribute -> RiskAssessment -> ControlStrategy
```
