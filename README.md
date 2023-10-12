# dw-prototyping

## 1. workload pattern description

## 2. data warehouse tech architecture consideration

long provisioned cluster vs serverless

purpose built dw engine vs hadoop eco-system


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
