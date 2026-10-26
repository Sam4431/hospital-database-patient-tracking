# Hospital Database: Patient & Treatment Analytics

## Project Overview
This project evaluates patient admission patterns, departmental length of stay, facility workloads, and emergency room utilization across a multi-facility healthcare system. Using a normalized relational database design and advanced MySQL analytics, the project identifies operational bottlenecks and provides actionable recommendations for hospital administration.

---

## Business Challenge
Hospital leadership needed to understand what factors drive extended inpatient stays, how emergency workloads are distributed across patient demographics and facilities, and how facility capacity constraints impact overall patient throughput[span_1](start_span)[span_1](end_span).

---

## Tools & Technologies Used
- Database Management: MySQL Workbench (Relational Database Design, DDL, DML)
- SQL Analytics: Multi-table joins, Window Functions (OVER (PARTITION BY), DENSE_RANK()), Conditional Aggregations (CASE mapping), and Views.
- Version Control: Git & GitHub

---

## Dataset Source & Link
- Dataset: Healthcare Analytics Dataset (Analytics Vidhya / Kaggle structure)
- Link: [Dataset Source Link Placeholder] *(Note: Raw data files are linked externally per repository organization standards[span_2](start_span)[span_2](end_span).)*

---

## Repository Structure
`text
hospital-database-patient-treatment-analytics/
├── data/
│   └── raw/              -- Link to source dataset[span_3](start_span)[span_3](end_span)
├── sql/
│   ├── schema.sql        -- Stage 1: Table DDL, keys, foreign keys, and indexes
│   └── analysis.sql      -- Stage 2 & Stretch: Documented analytical queries & views
├── images/
│   └── query_results.png -- Visual screenshots of key query outputs[span_4](start_span)[span_4](end_span)
└── README.md             -- Project documentation, findings, and reflections[span_5](start_span)[span_5](end_span)

Business QuestionKey Analytical MetricPrimary Insight / Result Summary
1. Average Length of Stay by DepartmentWeighted numeric midpoints of stay ranges (CASE mapping)Surgery (~37.4 days) and Radiotherapy (~33.2 days) record the longest average stays, driven by complex recovery cycles.
2. Facility Workload & Severity DistributionWindow functions (SUM OVER PARTITION) for % shareHigh-volume facilities skew heavily toward Moderate and Minor cases, while specialized centers shoulder critical case loads.
3. Age Groups & Emergency BurdenConditional aggregation (SUM CASE) and grand totalsMiddle-aged brackets (31–50) account for the largest overall share of emergency room visits system-weight.
4. Facility Performance & CapacityMulti-table joins aggregating extra rooms & bed gradesFacilities with low average extra rooms show higher operational strain, signaling physical bed constraints.

Actionable Recommendations for Hospital Administration
​Optimize Long-Stay Department Discharge Planning: Prioritize step-down care coordination and post-operative transition teams in Surgery and Radiotherapy to reduce bed lock and increase inpatient turnover.
​Targeted Preventive Care for Key Demographics: Allocate community healthcare resources and outpatient preventative interventions toward the 31–50 age group to reduce avoidable emergency room visits.
​Dynamic Facility Load Balancing: Monitor real-time available extra room metrics to divert non-emergency cases or reschedule elective procedures away from bottlenecked facilities.