# Phase Four DS Migration

## 1. get application id
```shell
var=$(cat applicationlist.txt|grep appid1)
applicationId=${var#* }
echo $applicationId

```
