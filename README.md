# Phase Two: GDM Job

In order to showcase the benefits of the to-be-upgraded data warehouse, three usecases have been tested, namely:
- athena query as dw tiering engine, data stored as csv; (refer to 3.2.1)
- athena query as dw tiering engine, data stored as parquet; (refer to 3.2.2)
- hive query powered by emr serverless as dw tiering engine, data stored as parquet. (refer to 3.2.3)

### 3.2.1 Athena as query engine, data stored as CSV

The space the raw CSV data stored in S3 takes up is shown per below snapshot:

<img width="1227" alt="Screenshot 2023-10-21 at 18 37 54" src="https://github.com/symeta/dw-prototyping/assets/97269758/577e700b-6bd2-4128-b8a0-39fd673dcbb8">


The query performance of the GDM job via athena is shown as per below snapshot:


<img width="515" alt="Screenshot 2023-10-22 at 20 22 43" src="https://github.com/symeta/dw-prototyping/assets/97269758/98f2e8c1-320a-409f-9483-9f6b91d3b0a1">


### 3.2.2 Athena as query engine, data stored as parquet


The space the parquet data stored in S3 takes up is shown per below snapshot:

<img width="1220" alt="Screenshot 2023-10-21 at 18 38 45" src="https://github.com/symeta/dw-prototyping/assets/97269758/ddb45153-df1f-4bee-96e1-b3aa85dee915">


The query performance of the GDM job via athena is shown as per below snapshot:

<img width="518" alt="Screenshot 2023-10-22 at 20 30 56" src="https://github.com/symeta/dw-prototyping/assets/97269758/14b66f6a-dfb2-4f0f-aa41-353c8635410b">


### 3.2.3 EMR Serverless hive as query engine, data stored as parquet

The query performance of the GDM job via EMR Serverless hive is shown as per below snapshot:


<img width="985" alt="Screenshot 2023-10-22 at 15 12 04" src="https://github.com/symeta/dw-prototyping/assets/97269758/aa57b2bb-82ae-4de2-b801-51d63eefa8f3">
