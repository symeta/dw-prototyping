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

job_state
{
  response4=$(aws emr-serverless get-job-run --application-id $applicationId --job-run-id $JOB_RUN_ID)
  jobRun=$(echo $response4 | jq -r '.jobRun')
  JOB_RUN_ID=$(echo $jobRun | jq -r '.jobRunId')
  JOB_STATE=$(echo $jobRun | jq -r '.state')
  echo $JOB_STATE
}

state=$(job_state)

while [ $state != "SUCCESS" ]; do
  case $state in
    RUNNING)
         state=$(job_state)
         ;;
    SCHEDULED)
         state=$(job_state)
         ;;
    PENDING)
         state=$(job_state)
         ;;
    FAILED)
         break
         ;;
   esac
done

if [ $state == "FAILED" ]
then
  false
else
  true
fi

```
