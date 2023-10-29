# Phase Three: Table Level Permission Control

## 3.3.1 Prototyping Objective Description
- Generally speaking, this phase of prototyping aims at showcaseing how to achieve **table level permission control** via athena.
- Specifically, this phase realizes a scenario enabling **an IAM user (namely dw-user1)** only has the permission to operate **table dim_date of database gdm_dw**. With this capability of athena, customer could design user permission sets according to their specific business logic.
- Emr serverless permission control is of a similar case.

## 3.3.2 Configuration Details
- create a IAM user group in IAM console with name **athena-gdm-dw-dim-date**

  <img width="1108" alt="Screenshot 2023-10-29 at 09 41 11" src="https://github.com/symeta/dw-prototyping/assets/97269758/5dfda7a0-a102-4476-a46a-3ed88c337a6e">

- create a permission policy named **gdm-access-test**

  <img width="1101" alt="278846702-313a96d7-89ad-4512-bdf1-8c5bae8252fb" src="https://github.com/symeta/dw-prototyping/assets/97269758/833c7c4c-eed5-40e5-aac7-936806e8df69">

  with the specific json statement as per below:
  ```json
  {
    "Version": "2012-10-17",
    "Statement": [
        {
            "Sid": "VisualEditor0",
            "Effect": "Allow",
            "Action": [
                "s3:ListStorageLensConfigurations",
                "s3:ListAccessPointsForObjectLambda",
                "s3:GetAccessPoint",
                "s3:PutAccountPublicAccessBlock",
                "s3:GetAccountPublicAccessBlock",
                "s3:ListAllMyBuckets",
                "s3:ListAccessPoints",
                "s3:PutAccessPointPublicAccessBlock",
                "s3:ListJobs",
                "s3:PutStorageLensConfiguration",
                "s3:ListMultiRegionAccessPoints",
                "s3:CreateJob"
            ],
            "Resource": "*"
        },
        {
            "Sid": "VisualEditor1",
            "Effect": "Allow",
            "Action": "s3:*",
            "Resource": [
                "arn:aws:s3:::tiger-dw-gdm/*",
                "arn:aws:s3:::ab23-athena-output/*",
                "arn:aws:s3:::ab23-athena-output",
                "arn:aws:s3:::tiger-dw-gdm"
            ]
        },
        {
            "Sid": "VisualEditor2",
            "Effect": "Allow",
            "Action": "glue:*",
            "Resource": [
                "arn:aws:glue:*:<aws account id>:catalog",
                "arn:aws:glue:us-west-2:<aws account id>:table/gdm_dw/dim_date",
                "arn:aws:glue:us-west-2:<aws account id>:database/gdm_dw"
            ]
        },
        {
            "Sid": "VisualEditor3",
            "Effect": "Allow",
            "Action": "athena:*",
            "Resource": [
                "arn:aws:athena:us-west-2:<aws account id>:datacatalog/AwsDataCatalog",
                "arn:aws:athena:us-west-2:<aws account id>:workgroup/primary"
            ]
        }
     ]
  }
  ```
  
- attach policy gdm-access-test to user group **athena-gdm-dw-dim-date**

  <img width="1115" alt="Screenshot 2023-10-29 at 09 44 05" src="https://github.com/symeta/dw-prototyping/assets/97269758/791051e3-e04c-4206-b1a8-1cdc6f200059">

- create a IAM user in IAM console with name **dw-user1**, and put the user into IAM user group **athena-gdm-dw-dim-date**

  <img width="1109" alt="Screenshot 2023-10-29 at 09 45 31" src="https://github.com/symeta/dw-prototyping/assets/97269758/a4e44920-e199-4218-9d88-858908b4acb7">


## 3.3.3 Permission Control Showcase



