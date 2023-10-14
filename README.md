# dw-prototyping

## 1. workload pattern description

**data warehouse production workload pattern**
- data warehouse tiering processes T+1 data in batch;
- 4 layers of the data warehouse;
- data warehouse tiering jobs take place during 1am and 5am per day;
- data warehouse processing engine currently leverages on hive, managed by HUE, job orchestrated by DolphinScheduler;

**data warehouse consumption workload pattern**
- end users view reports generated via data warehouse per week/month;
- end users query the tables of the data warehouse ad-hoc;
- query engine currently leverages on impala


## 2. data warehouse tech architecture consideration

the existing data warehouse is sitting on a long provisioned CDH cluster. Since the batch data processing workload lasts 5 hours per day during mid-night, with end user ad-hoc query follows a quite sparse pattern, it is recommended that the upgraded data warehouse leverages on serverless engine to achieve a cost performant way of building data warehouse.
customer is familiar with hive as well as impala, as a result, hive application @ emr serverless, as well as athena are considered as the processing as well as query engine of the upgraded data warehouse.


query engine:
athena query as dw tiering engine, data stored as csv
athena query as dw tiering engine, data stored as parquet
hive query powered by emr serverless as dw tiering engine, data stored as parquet

orchestration:
DolphinScheduler
Step Function

resource consumption granularity:
athena: by workgroup 
emr serverless hive: by application, by job

## 3.

### 3.1 athena query as dw tiering engine, data stored as csv

### 3.2 athena query as dw tiering engine, data stored as parquet

### 3.3 hive query powered by emr serverless as dw tiering engine, data stored as parquet

### 3.4 orchestrated by DolphinScheduler

### 3.5 orchestrated by Step Function

### 3.6 resource consumption statistics if via athena

### 3.7 resource consumotion statistics if via emr serverless

## 4 summary

## appendix: DolphinScheduler pseudo cluster installation guidance
