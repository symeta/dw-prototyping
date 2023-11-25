# Phase Four DS Migration

## 1. application id list persistance 
```shell

var=$(cat applicationlist.txt|grep appid1)
applicationId=${var#* }
echo $applicationId

```

## 2. enable ds step status auto-check via linux shell

```sh

app_state
{
  response2=$(aws emr-serverless get-application --application-id $applicationId)
  application=$(echo $response1 | jq -r '.application')
  state=$(echo $application | jq -r '.state')
  echo $state
}

state=$(app_state)

while [ $state!="SUCCESS"]; do
  sleep 10
done

```
