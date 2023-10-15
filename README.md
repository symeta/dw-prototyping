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

**Prototyping Architecture Diagram** 
is shown as below:

<img width="728" alt="image" src="https://github.com/symeta/dw-prototyping/assets/97269758/e36e2469-a5f3-492c-8dc8-3e2bc937faf0">

**pre-requisites**
- make sure the dev host has aws cli installed, to install aws cli, exec the cmd below

```sh
curl "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o "awscliv2.zip"
unzip awscliv2.zip
sudo ./aws/install

aws configure
#input IAM user's AK following the instruction guidance
#input IAM user's SK following the instruction guidance
#input region id that has enabled Bedrock, e.g. us-west-2
```


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
  ... ...
  `create_time` string,
  `update_time` string)
ROW FORMAT SERDE 'org.apache.hadoop.hive.serde2.OpenCSVSerde'
LOCATION 's3://shiyang/dw/ods/raw/cash_plus/am_deposit_withdrawal/'
```
- destination table is defined via the sql below
```sql
CREATE EXTERNAL TABLE `fdm_regular_saving_plan_order_a_d` (
  `pid` string, 
  ... ...
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
  ... ...
  `create_time` string,
  `update_time` string) 
PARTITIONED BY (data_year string) #set year as partition
STORED AS parquet
LOCATION 's3://shiyang-noaa-gsod-pds/dw/ods/parquet/cash_plus/am_deposit_withdrawal/'

#ingest data from csv data file to parquet data file
INSERT INTO parquet_cash_plus_am_deposit_withdrawal
SELECT id, 
  ... ...
  create_time,
  update_time,
  split_part(create_time,'-', 1) as data_year
FROM cash_plus_am_deposit_withdrawal;
```
the target data warehouse tiering job query result performance metrics are shown as below.

<img width="511" alt="Screenshot 2023-10-14 at 22 23 55" src="https://github.com/symeta/dw-prototyping/assets/97269758/daa62fc6-32cb-4408-bf81-4d964c54a12c">


### 3.3 hive query powered by emr serverless as dw tiering engine, data stored as parquet
emr serverless way of operating hive application consists of the following steps: 

- (1)create an IAM role that could enable the hive job access & operate relevant aws services; *one time execution* 
- (2)create a hive application; *once created if no job submitted, not resource consumption*
- (2)when the application state is "CREATED", start the application;
- (3)when the application state is "STARTED", submit the hive job;
- (4)when the job state is "Success", release the job;
- (5)if the job state is "Failed", need to debug based on the log information. 

**create IAM role**
```sh
aws iam create-role --role-name emr-serverless-job-role --assume-role-policy-document '{
    "Version": "2012-10-17",
    "Statement": [
      {
        "Effect": "Allow",
        "Principal": {
          "Service": "emr-serverless.amazonaws.com"
        },
        "Action": "sts:AssumeRole"
      }
    ]
  }'
```
- attach the role with policy to enable S3 bucket access

```sh
export BUCKET-NAME=<specific bucket name>

aws iam put-role-policy --role-name emr-serverless-job-role --policy-name S3Access --policy-document '{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Sid": "ReadFromOutputAndInputBuckets",
            "Effect": "Allow",
            "Action": [
                "s3:GetObject",
                "s3:ListBucket"
            ],
            "Resource": [
                "arn:aws:s3:::BUCKET-NAME",
                "arn:aws:s3:::BUCKET-NAME/*"
            ]
        },
        {
            "Sid": "WriteToOutputDataBucket",
            "Effect": "Allow",
            "Action": [
                "s3:PutObject",
                "s3:DeleteObject"
            ],
            "Resource": [
                "arn:aws:s3:::BUCKET-NAME/*"
            ]
        }
    ]
}'
```
- attach the role with policy to enable Glue permission

```sh
aws iam put-role-policy --role-name emr-serverless-job-role --policy-name GlueAccess --policy-document '{
    "Version": "2012-10-17",
    "Statement": [
      {
        "Sid": "GlueCreateAndReadDataCatalog",
        "Effect": "Allow",
        "Action": [
            "glue:GetDatabase",
            "glue:GetDataBases",
            "glue:CreateTable",
            "glue:GetTable",
            "glue:GetTables",
            "glue:GetPartition",
            "glue:GetPartitions",
            "glue:UpdateTable",
            "glue:CreatePartition",
            "glue:BatchCreatePartition",
            "glue:GetUserDefinedFunctions"
        ],
        "Resource": ["*"]
      }
    ]
  }'
```
- export the role's arn to be used in next step
```sh
export JOB_ROLE_ARN=arn:aws:iam::<aws account id>:role/emr-serverless-job-role
```

**create a hive application and submit hive job**

- create hive application
```sh
aws emr-serverless create-application \
  --type HIVE \
  --name <specific application name> \ 
  --release-label "emr-6.6.0" \
  --initial-capacity '{
        "DRIVER": {
            "workerCount": 1,
            "workerConfiguration": {
                "cpu": "2vCPU",
                "memory": "4GB",
                "disk": "30gb"
            }
        },
        "TEZ_TASK": {
            "workerCount": 10,
            "workerConfiguration": {
                "cpu": "4vCPU",
                "memory": "8GB",
                "disk": "30gb"
            }
        }
    }' \
  --maximum-capacity '{
        "cpu": "400vCPU",
        "memory": "1024GB",
        "disk": "1000GB"
    }'
```
after executing the cmd, a json response will return as below
```json
{
    "applicationId": "00et0f0b79s06o09",
    "arn": "arn:aws:emr-serverless:us-east-1:<aws account id>:/applications/00et0f0b79s06o09",
    "name": <specific application name>
}
```
- check the state of the hive application
```sh
export applicationId=00et0f0b79s06o09
aws emr-serverless get-application --application-id $applicationId
```
response like below could be acquired.
```json
{
    "application": {
        "applicationId": "00fdt9vnqe0p7u09",
        "name": <specific application name>,
        "arn": "arn:aws:emr-serverless:us-east-1:<aws account id>:/applications/00fdt9vnqe0p7u09",
        "releaseLabel": "emr-6.6.0",
        "type": "Hive",
        "state": "STARTED",
        "stateDetails": "AUTO_STOPPING",
        "initialCapacity": {
            "HiveDriver": {
                "workerCount": 1,
                "workerConfiguration": {
                    "cpu": "2 vCPU",
                    "memory": "4 GB",
                    "disk": "30 GB"
                }
            },
            "TezTask": {
                "workerCount": 10,
                "workerConfiguration": {
                    "cpu": "4 vCPU",
                    "memory": "8 GB",
                    "disk": "30 GB"
                }
            }
        },
        "maximumCapacity": {
            "cpu": "400 vCPU",
            "memory": "1024 GB",
            "disk": "1000 GB"
        },
        "createdAt": "2023-10-12T03:48:00.480000+00:00",
        "updatedAt": "2023-10-12T08:16:05.203000+00:00",
        "tags": {},
        "autoStartConfiguration": {
            "enabled": true
        },
        "autoStopConfiguration": {
            "enabled": true,
            "idleTimeoutMinutes": 15
        },
        "architecture": "X86_64"
    }
}
```
if the "state" is "STARTED", could further submit the hive job.

- submit the hive job
```sh
aws emr-serverless start-job-run \
    --application-id $applicationId \
    --execution-role-arn $JOB_ROLE_ARN \
    --job-driver '{
        "hive": {
            "initQueryFile": "s3://<bucket name>/<specific prefix>/create_fdm_table.sql", #DDL SQL for instance
            "query": "s3://<bucket name>/<specific prefix>/ingest_fdm_data.sql", #DML SQL for instance
            "parameters": "--hiveconf hive.exec.scratchdir=s3://<bucket name>/hive/scratch --hiveconf hive.metastore.warehouse.dir=s3://<bucket name>/hive/warehouse"
        }
    }' \
    --configuration-overrides '{
        "applicationConfiguration": [
            {
                "classification": "hive-site",
                "properties": {
                    "hive.driver.cores": "2",
                    "hive.driver.memory": "4g",
                    "hive.tez.container.size": "8192",
                    "hive.tez.cpu.vcores": "4"
                }
            }
        ],
        "monitoringConfiguration": {
            "s3MonitoringConfiguration": {
                "logUri": "s3://<bucket name>/hive-logs/"
            }
        }
    }'
```
the json formate response is as below.

```json
{
    "applicationId": "00fdt9vnqe0p7u09",
    "jobRunId": "00fdvr7mvngkk80a",
    "arn": "arn:aws:emr-serverless:us-east-1:<aws account id>:/applications/00fdt9vnqe0p7u09/jobruns/00fdvr7mvngkk80a"
}
```
execute the follow cmd to check the state of the job.
```sh
export JOB_RUN_ID=00fdvr7mvngkk80a
aws emr-serverless get-job-run --application-id $applicationId --job-run-id $JOB_RUN_ID
```

json format response is as below.

```json
{
    "jobRun": {
        "applicationId": "00fdt9vnqe0p7u09",
        "jobRunId": "00fdvr7mvngkk80a",
        "arn": "arn:aws:emr-serverless:us-east-1:<aws account id>:/applications/00fdt9vnqe0p7u09/jobruns/00fdvr7mvngkk80a",
        "createdBy": "arn:aws:sts::<aws account id>:assumed-role/PVRE-SSMOnboardingRole-18MA0VH7VUPOT/i-02d63cbb7fef34323",
        "createdAt": "2023-10-15T07:31:47.505000+00:00",
        "updatedAt": "2023-10-15T07:33:07.475000+00:00",
        "executionRole": "arn:aws:iam::<aws account id>:role/emr-serverless-job-role",
        "state": "RUNNING",
        "stateDetails": "",
        "releaseLabel": "emr-6.6.0",
        "configurationOverrides": {
            "applicationConfiguration": [
                {
                    "classification": "hive-site",
                    "properties": {
                        "hive.tez.cpu.vcores": "4",
                        "hive.driver.memory": "4g",
                        "hive.driver.cores": "2",
                        "hive.tez.container.size": "8192"
                    }
                }
            ],
            "monitoringConfiguration": {
                "s3MonitoringConfiguration": {
                    "logUri": "s3://<bucket name>/hive-logs/"
                },
                "managedPersistenceMonitoringConfiguration": {
                    "enabled": true
                }
            }
        },
        "jobDriver": {
            "hive": {
                "query": "s3://<bucket name>/<specific prefix>/ingest_fdm_data.sql",
                "initQueryFile": "s3://<bucket name>/<specific prefic>/create_fdm_table.sql",
                "parameters": "--hiveconf hive.exec.scratchdir=s3://<bucket name>/hive/scratch --hiveconf hive.metastore.warehouse.dir=s3://<bucket name>/hive/warehouse"
            }
        },
        "tags": {}
    }
}
```
if job success, the state will be "SUCCESS", if job fails, the state will be "FAILED", and reason why the job fails will be printed in the response for further debugging.

The job running status could be reviewed per below snapshot. Such metrics could be reviewed via the above "get-job-run" cmd also.

<img width="1262" alt="Screenshot 2023-10-15 at 15 41 16" src="https://github.com/symeta/dw-prototyping/assets/97269758/c452a910-7bee-4e44-a54b-4afbc413082b">

```json
        "totalResourceUtilization": {
            "vCPUHour": 1.097,
            "memoryGBHour": 2.194,
            "storageGBHour": 8.222
        },
        "totalExecutionDurationSeconds": 126
```


### 3.4 orchestrated by DolphinScheduler

orchestrating DAG diagram is shown as below.
below steps show how to orchestrate emr serverless hive application. Orchestrating athena query is behind these steps.
![image](https://github.com/symeta/dw-prototyping/assets/97269758/79a38760-193c-4313-9af0-43e43c87d928)

**orchestrate emr serverless hive application**
- create hive app
```sh
response1=$(aws emr-serverless create-application \
  --type HIVE \
  --name <specific application name> \ 
  --release-label "emr-6.6.0" \
  --initial-capacity '{
        "DRIVER": {
            "workerCount": 1,
            "workerConfiguration": {
                "cpu": "2vCPU",
                "memory": "4GB",
                "disk": "30gb"
            }
        },
        "TEZ_TASK": {
            "workerCount": 10,
            "workerConfiguration": {
                "cpu": "4vCPU",
                "memory": "8GB",
                "disk": "30gb"
            }
        }
    }' \
  --maximum-capacity '{
        "cpu": "400vCPU",
        "memory": "1024GB",
        "disk": "1000GB"
    }')

#get applicationId from reponse
applicationId=$(echo $response | jq -r '.applicationId')

#store applicationId into redis
redis-cli SET applicationId_LOB1 $applicationId
```

- check application state & start application & submit hive job
```sh

applicationId=$(redis cli GET applicationId_LOB1)

app_state{
  response2=$(aws emr-serverless get-application --application-id $applicationId)
  application=$(echo $response1 | jq -r '.application')
  state=$(echo $application | jq -r '.state')
  return state
}

state=app_state()
while [ $state!="CREATED" ]; do
  state=app_state()
done

response2=$(emr-serverless start-application --application-id $applicationId)
state=app_state()
while [ $state!="STARTED" ]; do
  state=app_state()
done

response3=$(aws emr-serverless start-job-run \
    --application-id $applicationId \
    --execution-role-arn $JOB_ROLE_ARN \
    --job-driver '{
        "hive": {
            "initQueryFile": "s3://shiyang-noaa-gsod-pds/create_table_1.sql",
            "query": "s3://shiyang-noaa-gsod-pds/extreme_weather_1.sql",
            "parameters": "--hiveconf hive.exec.scratchdir=s3://<bucket name>/hive/scratch --hiveconf hive.metastore.warehouse.dir=s3://<bucket name>/hive/warehouse"
        }
    }' \
    --configuration-overrides '{
        "applicationConfiguration": [
            {
                "classification": "hive-site",
                "properties": {
                    "hive.driver.cores": "2",
                    "hive.driver.memory": "4g",
                    "hive.tez.container.size": "8192",
                    "hive.tez.cpu.vcores": "4"
                }
            }
        ],
        "monitoringConfiguration": {
            "s3MonitoringConfiguration": {
                "logUri": "s3://<bucket name>/hive-logs/"
            }
        }
    }')

JOB_RUN_ID=$(echo $response3 | jq -r '.jobRunId')

#store job_run_id into redis
redis-cli SET job_run_id_LOB1 $JOB_RUN_ID


response4=$(aws emr-serverless get-job-run --application-id $applicationId --job-run-id $JOB_RUN_ID)

jobRun=$(echo $response4 | jq -r '.jobRun')
JOB_RUN_ID=$(echo $jobRun | jq -r '.jobRunId')
JOB_STATE=$(echo $jobRun | jq -r '.state')
```
- release resource when job completed
```sh
JOB_RUN_ID=$(redis-cli GET job_run_id_LOB1)
applicationId=$(redis-cli SET applicationID_LOB1)
response4=$(aws emr-serverless get-job-run --application-id $applicationId --job-run-id $JOB_RUN_ID)

jobRun=$(echo $response4 | jq -r '.jobRun')
JOB_STATE=$(echo $jobRun | jq -r '.state')

#if failed, send alert
#if pending, send timeout alert
#if success, release resource
aws emr-serverless stop-application --application-id $APPLICATION_ID
aws emr-serverless delete-application --application-id $APPLICATION_ID
```

**orchestrate athena query**
```sh
aws athena start-query-execution \
    --query-string "select date, location, browser, uri, status from cloudfront_logs where method = 'GET' and status = 200 and location like 'SFO%' limit 10" \
    --work-group "AthenaAdmin" 
```
get the response:
```json
{
"QueryExecutionId": "a1b2c3d4-5678-90ab-cdef-EXAMPLE11111"
}
```
could get query status by

```sh
aws athena get-query-execution \
    --query-execution-id a1b2c3d4-5678-90ab-cdef-EXAMPLE11111
```
get the response:

```json
{
    "QueryExecution": {
        "QueryExecutionId": "a1b2c3d4-5678-90ab-cdef-EXAMPLE11111",
        "Query": "select date, location, browser, uri, status from cloudfront_logs where method = 'GET
' and status = 200 and location like 'SFO%' limit 10",
        "StatementType": "DML",
        "ResultConfiguration": {
            "OutputLocation": "s3://awsdoc-example-bucket/a1b2c3d4-5678-90ab-cdef-EXAMPLE11111.csv"
        },
        "QueryExecutionContext": {
            "Database": "mydatabase",
            "Catalog": "awsdatacatalog"
        },
        "Status": {
            "State": "SUCCEEDED",
            "SubmissionDateTime": 1593469842.665,
            "CompletionDateTime": 1593469846.486
        },
        "Statistics": {
            "EngineExecutionTimeInMillis": 3600,
            "DataScannedInBytes": 203089,
            "TotalExecutionTimeInMillis": 3821,
            "QueryQueueTimeInMillis": 267,
            "QueryPlanningTimeInMillis": 1175
        },
        "WorkGroup": "AthenaAdmin"
    }
}
```
orchestrator can leverage on these commands as well as information to orchestrate.

### 3.5 orchestrated by Step Function (optional)

TBW

### 3.6 resource consumption statistics if via athena
in terms of resource consumption granularity, athena is by workgroup, meaning that each workgroup can be attached a specific cost allocation tag and resource consumption of this workgroup could be viewed via cost explorer as well as billing.

athena workgroup could be tagged via cmd as below:
```sh
aws athena tag-resource \
    --resource-arn arn:aws:athena:us-east-1:<aws account id>:workgroup/primary \
    --tags Key=CostCenter,Value=123
```
after cost allocation tag is created, it should be activated in Billing Console --> Cost Allocation Tags

### 3.7 resource consumotion statistics if via emr serverless
in temrs of resource consumption granulartiy, emr serverless hive supports both by application and by job, meaning that either application or job can be attached a specific cost allocation tag and resource consumption of either an application or a job could be viewed via cost explorer as well as billing.

emr serverless hive application and job could be tagged via creation.
```sh
  --tag '{
    "CostCenter": "123"
  }'
```

## 4 summary
- the raw data volume is 450MB in csv format. If stored as parquet, 75MB. Compression Ratio can achieve to 6
- the target data warehouse tiering job is completed in 4.626 seconds via athena, with data stored as parquet
- the same job is completed in 5.489 seconds via athena, with data stored as csv
- the same job is complted in 2 minutes via emr serverless hive application
- athena query is easier to be orchestrated than emr serverless hive application

As a result, it is recommended:
- to use parquet to store data;
- to leverage on athena as the data warehouse tiering engine from a performance perspective.

Cost analysis TBW.

## appendix: DolphinScheduler pseudo cluster installation guidance

TBW
