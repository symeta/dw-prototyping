#install TiUP, dumpling tool
curl --proto '=https' --tlsv1.2 -sSf https://tiup-mirrors.pingcap.com/install.sh | sh

cd /root
source .bash_profile

tiup --version

tiup install dumpling

tiup dumpling -u <prefix.root> -P 4000 -h <tidb serverless endpoint/host> -r 200000 -o "s3://<speific s3 bucket>" --sql "select * from <target database>.<target tabke>" --ca "/etc/pki/tls/certs/ca-bundle.crt" --password <tidb serverless password>

tiup dumpling -u <prefix.root> -P 4000 -h <tidb serverless endpoint/host> -r 200000 -o "s3://<speific s3 bucket>" --sql "select * from <target database>.<target tabke> where id > 2" --ca "/etc/pki/tls/certs/ca-bundle.crt" --password <tidb serverless password>
