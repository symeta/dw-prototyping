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
In order to showcase the benefits of the to-be-upgraded data warehouse, three usecases have been tested, namely:
- athena query as dw tiering engine, data stored as csv; (refer to 3.1)
- athena query as dw tiering engine, data stored as parquet; (refer to 3.2)
- hive query powered by emr serverless as dw tiering engine, data stored as parquet. (refer to 3.3)

Orchestrator wise, operation guidance of orchestrating athena query as well as hive application via DolphinScheduler is provided. Step Function way is discussed. (refer to 3.4, 3.5)

Customer is keen at finding out a way to know the resource consumption each end user consumes. As a result, the mechanism of both athena and emr serverless achieving this objective is introduced. (refer to 3.6, 3.7)

Prototyping Architecture Diagram is shown as below:


### 3.1 athena query as dw tiering engine, data stored as csv
- original csv data files uploaded to S3 bucket, via web console, or via command line.
```sh
aws s3 cp <csv data file> s3://<s3 bucket>/<specific prefix>/<csv data file>
#sample command line
aws s3 cp cash_plus.am_deposit_withdrawal.csv s3://shiyang/dw/ods/raw/cash_plus/am_deposit_withdrawal/cash_plus.am_deposit_withdrawal.csv
```
- map the csv data file with hive table via the sql below. There are 8 target tables, 1 is shown for instance.
```sql
CREATE EXTERNAL TABLE IF NOT EXISTS `cash_plus_am_deposit_withdrawal`(
  `id` string, 
  `uuid` string, 
  `external_id` string, 
  `order_id` string, 
  `account` string, 
  `sec_type` string, 
  `product_id` string, 
  `symbol` string, 
  `direction` string, 
  `seg_type` string, 
  `currency` string, 
  `trade_currency` string, 
  `amount` string, 
  `purchase_fee` string, 
  `purchase_fee_gst` string, 
  `trade_time` string, 
  `effective_time` string, 
  `priced_time` string, 
  `nav` string, 
  `nav_date` string, 
  `shares` string, 
  `avg_nav` string, 
  `realized_pnl` string, 
  `bs_id` string, 
  `bs_time` string, 
  `reason` string, 
  `type` string, 
  `payment_method` string,
  `payment_detail` string,
  `order_type` string,
  `routing_key` string,
  `oae_id` string,
  `status` string,
  `attrs` string,
  `create_time` string,
  `update_time` string)
ROW FORMAT SERDE 'org.apache.hadoop.hive.serde2.OpenCSVSerde'
LOCATION 's3://shiyang/dw/ods/raw/cash_plus/am_deposit_withdrawal/'
```
- destination table is defined via the sql below
```sql
CREATE EXTERNAL TABLE `fdm_regular_saving_plan_order_a_d` (
  `pid` string, 
  `order_id` string, 
  `uuid` string, 
  `omni_order_id` string, 
  `account_id` string, 
  `account` string, 
  `sec_type` string, 
  `product_id` string, 
  `symbol` string, 
  `direction` string, 
  `seg_type` string, 
  `currency` string, 
  `amount` string, 
  `purchase_fee` string, 
  `purchase_fee_gst` string, 
  `trade_time` string, 
  `effective_time` string, 
  `priced_time` string, 
  `nav` string, 
  `nav_date` string, 
  `shares` string, 
  `avg_nav` string, 
  `realized_pnl` string, 
  `bs_id` string, 
  `bs_time` string, 
  `reason` string, 
  `type` string, 
  `payment_method` string,
  `payment_detail` string,
  `status` string,
  `rsp_id` string,
  `rsp_order_type` string,
  `rsp_order_status` string,
  `create_time` string,
  `update_time` string,
  `is_rsp_order` int,
  `data_flag` string)
STORED AS parquet
LOCATION 's3://shiyang-noaa-gsod-pds/dw/fdm/'
```
the target data warehouse tiering job query result performance metrics are shown as below.

<img width="518" alt="Screenshot 2023-10-14 at 22 13 51" src="https://github.com/symeta/dw-prototyping/assets/97269758/501c82f8-c5ee-4afb-a618-cf6dc297be46">

### 3.2 athena query as dw tiering engine, data stored as parquet
- convert csv data file to parquet data file
```sql
# parquet table DDL, for large files, consider leveraging on partition.
CREATE EXTERNAL TABLE `parquet_cash_plus_am_deposit_withdrawal` (
  `id` string, 
  `uuid` string, 
  `external_id` string, 
  `order_id` string, 
  `account` string, 
  `sec_type` string, 
  `product_id` string, 
  `symbol` string, 
  `direction` string, 
  `seg_type` string, 
  `currency` string, 
  `trade_currency` string, 
  `amount` string, 
  `purchase_fee` string, 
  `purchase_fee_gst` string, 
  `trade_time` string, 
  `effective_time` string, 
  `priced_time` string, 
  `nav` string, 
  `nav_date` string, 
  `shares` string, 
  `avg_nav` string, 
  `realized_pnl` string, 
  `bs_id` string, 
  `bs_time` string, 
  `reason` string, 
  `type` string, 
  `payment_method` string,
  `payment_detail` string,
  `order_type` string,
  `routing_key` string,
  `oae_id` string,
  `status` string,
  `attrs` string,
  `create_time` string,
  `update_time` string) 
PARTITIONED BY (data_year string) #set year as partition
STORED AS parquet
LOCATION 's3://shiyang-noaa-gsod-pds/dw/ods/parquet/cash_plus/am_deposit_withdrawal/'

#ingest data from csv data file to parquet data file
INSERT INTO parquet_cash_plus_am_deposit_withdrawal
SELECT id, 
  uuid, 
  external_id, 
  order_id, 
  account, 
  sec_type, 
  product_id, 
  symbol, 
  direction, 
  seg_type, 
  currency, 
  trade_currency, 
  amount, 
  purchase_fee, 
  purchase_fee_gst, 
  trade_time, 
  effective_time, 
  priced_time, 
  nav, 
  nav_date, 
  shares, 
  avg_nav, 
  realized_pnl, 
  bs_id, 
  bs_time, 
  reason, 
  type, 
  payment_method,
  payment_detail,
  order_type,
  routing_key,
  oae_id,
  status,
  attrs,
  create_time,
  update_time,
  split_part(create_time,'-', 1) as data_year
FROM cash_plus_am_deposit_withdrawal;
```
the target data warehouse tiering job query result performance metrics are shown as below.

<img width="511" alt="Screenshot 2023-10-14 at 22 23 55" src="https://github.com/symeta/dw-prototyping/assets/97269758/daa62fc6-32cb-4408-bf81-4d964c54a12c">


### 3.3 hive query powered by emr serverless as dw tiering engine, data stored as parquet


### 3.4 orchestrated by DolphinScheduler

### 3.5 orchestrated by Step Function

### 3.6 resource consumption statistics if via athena

resource consumption granularity:
athena: by workgroup 
emr serverless hive: by application, by job

### 3.7 resource consumotion statistics if via emr serverless

## 4 summary

## appendix: DolphinScheduler pseudo cluster installation guidance
