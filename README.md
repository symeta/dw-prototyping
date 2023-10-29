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

the existing data warehouse is sitting on a long provisioned CDH cluster. Since the batch data processing workload lasts 5 hours per day during mid-night, with end user ad-hoc query follows a quite sparse pattern, it is recommended that the to-be-upgraded data warehouse leverages on serverless engine to achieve a cost performant way of building data warehouse.

customer is familiar with hive as well as impala, as a result, hive application @ emr serverless, as well as athena are considered as the processing as well as query engine of the to-be-upgraded data warehouse.

DolphinScheduler remains to be the job orchestrator, since customer is familiar with its operations. While Step Function which is an aws native job orchestrator is suggested.

## 3. Prototyping Detail

[3.1 Phase One: FDM Job](https://github.com/symeta/dw-prototyping/blob/phase1/README.md)

[3.2 Phase Two: GDM Job](https://github.com/symeta/dw-prototyping/blob/phase2/README.md)

[3.3 Phase Three: Table Level Permission Control](https://github.com/symeta/dw-prototyping/blob/phase3/README.md)


## appendix: DolphinScheduler pseudo cluster installation guidance

TBW
