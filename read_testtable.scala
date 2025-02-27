package com.example
import org.apache.spark.sql.{DataFrame, SparkSession}

object Main  {

  def main(args: Array[String]): Unit = {

    val spark = SparkSession.builder()
      .appName("<specific app name>")
      .enableHiveSupport()
      .getOrCreate()

    spark.sql("show databases").show()
    spark.sql("use default")
    var df=spark.sql("select * from testtable")

    df.write
      .format("jdbc")
      .option("driver","com.mysql.cj.jdbc.Driver")
      .option("url", "jdbc:mysql://<tidbcloud_endpoint>:4000/namespace")
      .option("dbtable", "<table_name>")
      .option("user", "<use_name>")
      .option("password", "<password_string>")
      .save()

    spark.close()
  }
}
