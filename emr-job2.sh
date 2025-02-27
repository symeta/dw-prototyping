export applicationId=00fev6mdk***

export job_role_arn=arn:aws:iam::<aws account id>:role/emr-serverless-job-role

aws emr-serverless start-job-run \
    --application-id $applicationId \
    --execution-role-arn $job_role_arn \
    --job-driver '{
        "sparkSubmit": {
            "entryPoint": "<s3 object url for the python script file>",
            "entryPointArguments": ["testspark"],
            "sparkSubmitParameters": "--conf spark.hadoop.hive.metastore.client.factory.class=com.amazonaws.glue.catalog.metastore.AWSGlueDataCatalogHiveClientFactory --conf spark.driver.cores=1 --conf spark.driver.memory=3g --conf spark.executor.cores=4 --conf spark.executor.memory=3g --jars s3://spark-sql-test-nov23rd/mysql-connector-j-8.2.0.jar"
        }
    }'
