sudo dnf install java-1.8.0-amazon-corretto
java -version

cd /usr/local/src
wget https://archive.apache.org/dist/zookeeper/zookeeper-3.8.0/apache-zookeeper-3.8.0-bin.tar.gz 
tar -zxvf apache-zookeeper-3.8.0-bin.tar.gz

cd apache-zookeeper-3.8.0-bin/conf
cp zoo_sample.cfg zoo.cfg
cd ..

nohup bin/zkServer.sh start-foreground &> nohup_zk.out &
bin/zkServer.sh status

python3 --version

cd /usr/local/src  
wget https://dlcdn.apache.org/dolphinscheduler/3.1.9/apache-dolphinscheduler-3.1.9-bin.tar.gz
tar -zxvf apache-dolphinscheduler-3.1.9-bin.tar.gz
mv apache-dolphinscheduler-3.1.9-bin apache-dolphinscheduler

wget https://downloads.mysql.com/archives/get/p/3/file/mysql-connector-j-8.0.31.tar.gz   
tar -zxvf mysql-connector-j-8.0.31.tar.gz

cp mysql-connector-j-8.0.31/mysql-connector-j-8.0.31.jar ./apache-dolphinscheduler/api-server/libs/
cp mysql-connector-j-8.0.31/mysql-connector-j-8.0.31.jar ./apache-dolphinscheduler/alert-server/libs/
cp mysql-connector-j-8.0.31/mysql-connector-j-8.0.31.jar ./apache-dolphinscheduler/master-server/libs/  
cp mysql-connector-j-8.0.31/mysql-connector-j-8.0.31.jar ./apache-dolphinscheduler/worker-server/libs/  
cp mysql-connector-j-8.0.31/mysql-connector-j-8.0.31.jar ./apache-dolphinscheduler/tools/libs/


useradd dolphinscheduler 
echo "dolphinscheduler" | passwd --stdin dolphinscheduler  

sed -i '$adolphinscheduler ALL=(ALL) NOPASSWD: NOPASSWD: ALL' /etc/sudoers

sed -i 's/Defaults   requirett/#Defaults requirett/g' /etc/sudoers

chown -R dolphinscheduler:dolphinscheduler apache-dolphinscheduler 

sudo dnf update -y
sudo dnf install mariadb105

mysql -h <RDS for mysql Endpoint> -u admin -p

mysql> CREATE DATABASE dolphinscheduler DEFAULT CHARACTER SET utf8 DEFAULT COLLATE utf8_general_ci;

mysql>exit;

cd /usr/local/src/apache-dolphinscheduler/

#revise dolphinscheduler_env.sh
vim bin/env/dolphinscheduler_env.sh

export DATABASE=${DATABASE:-mysql}   
export SPRING_PROFILES_ACTIVE=${DATABASE}  
export SPRING_DATASOURCE_URL="jdbc:mysql://ds-mysql.cq**********.us-east-1.rds.amazonaws.com/dolphinscheduler?useUnicode=true&characterEncoding=UTF-8&useSSL=false"   
export SPRING_DATASOURCE_USERNAME="admin"  
export SPRING_DATASOURCE_PASSWORD="<your password>"

#revise install_env.sh
vim bin/env/install_env.sh

ips=${ips:-"<private ip address of ds-pseudo EC2 instance>"}  
masters=${masters:-"< private ip address of ds-pseudo EC2 instance >"}
workers=${workers:-" private ip address of ds-pseudo EC2 instance:default"}
alertServer=${alertServer:-" private ip address of ds-pseudo EC2 instance "}
apiServers=${apiServers:-" private ip address of ds-pseudo EC2 instance "}
installPath=${installPath:-"~/dolphinscheduler"}

export JAVA_HOME=${JAVA_HOME:-/usr/lib/jvm/jre-1.8.0-openjdk}
export PYTHON_HOME=${PYTHON_HOME:-/bin/python3}


cd /usr/local/src/apache-dolphinscheduler/
bash tools/bin/upgrade-schema.sh

cd /usr/local/src/apache-dolphinscheduler/
su dolphinscheduler  
bash ./bin/install.sh

cd /usr/local/src/apache-dolphinscheduler/
su dolphinscheduler  
bash ./bin/start-all.sh

