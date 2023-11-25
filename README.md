# Phase Five: EMR Serverless Spark Job 

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
    spark.close()
  }

}
```

- aws cli submit spark JAR job

```sh

aws emr-serverless start-job-run \
    --application-id application-id \
    --execution-role-arn job-role-arn \
    --job-driver '{
        "sparkSubmit": {
            "entryPoint": "s3://<s3 bucekt>/scripts/***.jar",
            "sparkSubmitParameters": "--conf spark.hadoop.hive.metastore.client.factory.class=com.amazonaws.glue.catalog.metastore.AWSGlueDataCatalogHiveClientFactory --conf spark.driver.cores=1 --conf spark.driver.memory=3g --conf spark.executor.cores=4 --conf spark.executor.memory=3g"
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



