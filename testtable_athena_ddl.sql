CREATE EXTERNAL TABLE IF NOT EXISTS `testtable`(
  `id` string
) 
ROW FORMAT SERDE 'org.apache.hadoop.hive.serde2.OpenCSVSerde'
LOCATION 's3://<bucket_name>/<prefix_name>/';  
