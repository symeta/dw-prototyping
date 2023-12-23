# Phase Six: EMR Serverless Spark Job - Glue Table as Source, TiDB Table as Destination 

## 1. submit JAR file mode

- scala source code

```scala

package com.shiyang
import org.apache.spark.sql.{DataFrame, SparkSession}

object Main  {

  def main(args: Array[String]): Unit = {

    val spark = SparkSession.builder()
      .appName("shiyang1")
      .enableHiveSupport()
      .getOrCreate()

    spark.sql("show databases").show()
    spark.sql("use default")
    var df=spark.sql("select * from testspark")

    df.write
      .format("jdbc")
      .option("driver","com.mysql.cj.jdbc.Driver")
      .option("url", "jdbc:mysql://gateway01.ap-southeast-1.prod.aws.tidbcloud.com:4000/test")
      .option("dbtable", "testtable3")
      .option("user", "3Je***.root")
      .option("password", "DIk***")
      .save()

    spark.close()
  }

}
```

- aws cli submit spark JAR job

```sh

export applicationId=00fev6mdk***

export job_role_arn=arn:aws:iam::<aws account id>:role/emr-serverless-job-role

aws emr-serverless start-job-run \
    --application-id $applicationId \
    --execution-role-arn $job_role_arn \
    --job-driver '{
        "sparkSubmit": {
            "entryPoint": "s3://spark-sql-test-nov23rd/scripts/dec13-1/scala-glue_2.13-1.0.1.jar",
            "sparkSubmitParameters": "--conf spark.hadoop.hive.metastore.client.factory.class=com.amazonaws.glue.catalog.metastore.AWSGlueDataCatalogHiveClientFactory --conf spark.driver.cores=1 --conf spark.driver.memory=3g --conf spark.executor.cores=4 --conf spark.executor.memory=3g --jars s3://spark-sql-test-nov23rd/mysql-connector-j-8.2.0.jar"
        }
    }'

```

- sbt build.sbt config

```txt
scalaVersion := "2.13.8"
val sparkVersion = "3.2.1"
libraryDependencies += "org.apache.spark" %% "spark-sql" % sparkVersion % "provided"

name := "scala-glue"
organization := "com.shiyang"
version := "1.0.1"

```

- sbt command

```sh
sbt clean
sbt package

```
sbt project build guidance:
https://www.youtube.com/watch?v=0yyw2gD0SrY


## 2. submit .py file mode

- python script

```python
import os
import sys
import pyspark.sql.functions as F
from pyspark.sql import SparkSession

if __name__ == "__main__":

    spark = SparkSession\
        .builder\
        .appName("app1")\
        .enableHiveSupport()\
        .getOrCreate()

    df=spark.sql(f"select * from {str(sys.argv[1])}")

    df.write.format("jdbc").options(
        driver="com.mysql.cj.jdbc.Driver",
        url="jdbc:mysql://gateway01.ap-southeast-1.prod.aws.tidbcloud.com:4000/test",
        dbtable="testtable1",
        user="3JePguGPZ9f8CHv.root",
        password="DIkq8yg8wjXbAhqb").save()

    spark.stop()

```

- aws cli submit python job

```sh

export applicationId=00fev6mdk***

export job_role_arn=arn:aws:iam::<aws account id>:role/emr-serverless-job-role

aws emr-serverless start-job-run \
    --application-id $applicationId \
    --execution-role-arn $job_role_arn \
    --job-driver '{
        "sparkSubmit": {
            "entryPoint": "s3://spark-sql-test-nov23rd/scripts/dec13-1/testpython.py",
            "sparkSubmitParameters": "--conf spark.hadoop.hive.metastore.client.factory.class=com.amazonaws.glue.catalog.metastore.AWSGlueDataCatalogHiveClientFactory --conf spark.driver.cores=1 --conf spark.driver.memory=3g --conf spark.executor.cores=4 --conf spark.executor.memory=3g --jars s3://spark-sql-test-nov23rd/mysql-connector-j-8.2.0.jar"
        }
    }'

```

## 3. common part
- emr serverless application network configuration

```txt
* choose vpc
* choose private subnet
* create NAT GW of the subnet, or make sure that the destination table is reachable
```
- TiDB Configuration

```sh
set global tidb_skip_isolation_level_check=1;
```
