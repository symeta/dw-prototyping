# ds pseudo cluster installation guidance

## pre-requisite
- jvm is installed on the host

## install mysql connnector
```sh
wget https://downloads.mysql.com/archives/get/p/3/file/mysql-connector-j-8.0.31.tar.gz   
tar -zxvf mysql-connector-j-8.0.31.tar.gz 
```

## install zookeeper
```sh
wget https://archive.apache.org/dist/zookeeper/zookeeper-3.8.0/apache-zookeeper-3.8.0-bin.tar.gz 
tar -zxvf apache-zookeeper-3.8.0-bin.tar.gz
```

## download dolphinscheduler package
```sh
wget https://dlcdn.apache.org/dolphinscheduler/3.1.8/apache-dolphinscheduler-3.1.8-bin.tar.gz
tar -zxvf apache-dolphinscheduler-3.1.8-bin.tar.gz
```

## copy mysql-connector-j.jar to each dir of dolphinscheduler modules
```sh
cp mysql-connector-j-8.0.31/mysql-connector-j-8.0.31.jar ./apache-dolphinscheduler-3.1.8-bin/api-server/libs/

cp mysql-connector-j-8.0.31/mysql-connector-j-8.0.31.jar ./apache-dolphinscheduler-3.1.8-bin/alert-server/libs/

cp mysql-connector-j-8.0.31/mysql-connector-j-8.0.31.jar ./apache-dolphinscheduler-3.1.8-bin/master-server/libs/  

cp mysql-connector-j-8.0.31/mysql-connector-j-8.0.31.jar ./apache-dolphinscheduler-3.1.8-bin/worker-server/libs/  

cp mysql-connector-j-8.0.31/mysql-connector-j-8.0.31.jar ./apache-dolphinscheduler-3.1.8-bin/tools/libs/
```
## provision an RDS for mysql instance via aws console

```sh
mysql> CREATE DATABASE dolphinscheduler DEFAULT CHARACTER SET utf8 DEFAULT COLLATE utf8_general_ci; 

mysql> GRANT ALL PRIVILEGES ON dolphinscheduler.* TO 'admin'@'%';  

mysql> GRANT ALL PRIVILEGES ON dolphinscheduler.* TO 'admin'@'localhost';   

mysql> FLUSH PRIVILEGES;  


# Database related configuration, set database type, username and password # 修改 {mysql-endpoint} 为你 mysql 连接地址  
# 修改 {user} 和 {password} 为你 mysql ⽤户名和密码，{rds-endpoint}为数据库连接地址
export DATABASE=${DATABASE:-mysql}   
export SPRING_PROFILES_ACTIVE=${DATABASE}  
export SPRING_DATASOURCE_URL="jdbc:mysql://database-1.cluster-ckijl4cofaxc.us-east-1.rds.amazonaws.com/dolphinscheduler?useUnicode=true&characterEncoding=UTF-8&useSSL=false"   
export SPRING_DATASOURCE_USERNAME=admin  
export SPRING_DATASOURCE_PASSWORD=Huawei12#$  
  
# 执行数据初始化  
bash apache-dolphinscheduler/tools/bin/upgrade-schema.sh

```


