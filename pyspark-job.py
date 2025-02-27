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
        url="jdbc:mysql://tidbcloud_endpoint:4000/namespace ",
        dbtable="table_name",
        user="use_name",
        password="password_string").save()

    spark.stop()
