Hive -f example.sql

#revise /usr/local/src/apache-dolphinscheduler/api-server/conf as below

#revise /usr/local/src/apache-dolphinscheduler/worker-server/conf as below

# resource storage type: HDFS, S3, OSS, NONE
#resource.storage.type=NONE
resource.storage.type=S3
# resource store on HDFS/S3 path, resource file will store to this base path, self configuration, please make sure the directory exists on hdfs and have read write permissions. "/dolphinscheduler" is recommended
resource.storage.upload.base.path=/dolphinscheduler

# The AWS access key. if resource.storage.type=S3 or use EMR-Task, This configuration is required
resource.aws.access.key.id=AKIA************
# The AWS secret access key. if resource.storage.type=S3 or use EMR-Task, This configuration is required
resource.aws.secret.access.key=lAm8R2TQzt*************
# The AWS Region to use. if resource.storage.type=S3 or use EMR-Task, This configuration is required
resource.aws.region=us-east-1
# The name of the bucket. You need to create them by yourself. Otherwise, the system cannot start. All buckets in Amazon S3 share a single namespace; ensure the bucket is given a unique name.
resource.aws.s3.bucket.name=dolphinscheduler-shiyang
# You need to set this parameter when private cloud s3. If S3 uses public cloud, you only need to set resource.aws.region or set to the endpoint of a public cloud such as S3.cn-north-1.amazonaws.com.cn
resource.aws.s3.endpoint=s3.us-east-1.amazonaws.com


cd /usr/local/src/apache-dolphinscheduler/

bash ./bin/stop-all.sh
bash ./bin/start-all.sh
bash ./bin/status-all.sh
