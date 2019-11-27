# Reporting developers guide

## Oveview

Let's imagine we have the following tests structure:

```
(Suite) Services
    (Test) PluginServiceTest
        (Step) uploadPlugin
        (Step) updatePlugin
        (Step) removePlugin
    (Test) UserServiceTest
        (Step) createUser
        (Step) updateUser
        (Step) deleteUser
``` 

So our goal is run the test and send results to Report Portal.
We can interact with Report Portal API instance trough HTTP requests.

The main flow is set of HTTP requests:
1. Start launch
2. Start test item 
3. Save log with attachment if necessary
4. Finish test item
5. Finish launch

Steps 2-4 should execute for each test item in structure.

## Preconditions 

Let's assume that our Report Portal instance deployed at `http://rp.com`.
And we have api key `039eda00-b397-4a6b-bab1-b1a9a90376d1`. You can find it in profile (`http://rp.com/ui/#user-profile`).
And our project name is `rp_project`.


## Start launch

To start launch you should send request to the following endpoint:
POST `/api/{version}/{projectName}/launch`

Start launch request model contains the following attributes:

|  Attribute  | Required | Description                                                              | Default value       | Examples                                                                                                                                                             |
|:-----------:|----------|--------------------------------------------------------------------------|---------------------|----------------------------------------------------------------------------------------------------------------------------------------------------------------------|
| name        | Yes      | Name of launch                                                           | -                   | AutomationRun                                                                                                                                                        |
| startTime   | Yes      | Launch start time                                                        | -                   | 2019-11-22T11:47:01+00:00 (ISO 8601) Fri, 22 Nov 2019 11:47:01 +0000 (RFC 822, 1036, 1123, 2822) 2019-11-22T11:47:01+00:00 (RFC 3339) 1574423221000 (Unix Timestamp) |
| description | No       | Description of launch                                                    | empty               | Services tests                                                                                                                                                       |
| uuid        | No       | Launch uuid (string identificator)                                       | auto generated UUID | 69dc75cd-4522-44b9-9015-7685ec0e1abb                                                                                                                                 |
| attributes  | No       | Launch attributes(tags). Pairs of key and value                          | empty               | build:3.0.1 os:bionic                                                                                                                                                |
| mode        | No       | Launch mode. Allowable values 'default' or 'debug'                       | default             | DEFAULT                                                                                                                                                              |
| rerun       | No       | Rerun mode. Allowable values 'true' of 'false'                           | false               | false                                                                                                                                                                |
| rerunOf     | No       | Rerun mode. Specifies launch to be reruned. Uses with 'rerun' attribute. | empty               | 694e1549-b8ab-4f20-b7d8-8550c92431b0                                                                                                                                 |

Start launch response contains the following attributes:

| Attribute | Required | Description              | Examples                             |
|-----------|----------|--------------------------|--------------------------------------|
| id        | Yes      |  UUID of created launch  | 1d1fb22e-01f7-4ac9-9ebc-f020d8fe93ff |
| number    | No       | Number of created launch | 1                                    |

So full request to start our launch looks like 

```shell script
curl --header "Content-Type: application/json" \
     --header "Authorization: Bearer 039eda00-b397-4a6b-bab1-b1a9a90376d1" \
     --request POST \
     --data 'body' \
     http://rp.com/api/v1/rp_project/launch
```

Where body is the following json:

```json
{
   "name": "rp_launch",
   "description": "My first launch on RP",
   "startTime": "1574423221000",
   "mode": "DEFAULT",
   "attributes": [
     {
       "key": "build",
       "value": "0.1"
     },
     {
       "value": "test"
     }   
   ] 
 }
```

In the response we can see `id` and `number` if launch started successfully or an error if something went wrong. 

```json
{
  "id": "96d1bc02-6a3f-451e-b706-719149d51ce4",
  "number": 1
}
```
Value of `id` field should save somewhere. It will be used later to report test items.

## Start suite(root) item

Now we have created launch and can report items under it.
To start root item you should send request to the following endpoint:
POST `/api/{version}/{projectName}/item`

Start test item request model contains the following attributes:

| Attribute   | Required | Description                                                                                                                                                                                                                                         | Default value  | Examples                                                                                                                                                             |
|-------------|----------|-----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------|----------------|----------------------------------------------------------------------------------------------------------------------------------------------------------------------|
| name        | Yes      | Name of test item                                                                                                                                                                                                                                   | -              | Logging Tests                                                                                                                                                        |
| startTime   | Yes      | Test item start time                                                                                                                                                                                                                                | -              | 2019-11-22T11:47:01+00:00 (ISO 8601) Fri, 22 Nov 2019 11:47:01 +0000 (RFC 822, 1036, 1123, 2822) 2019-11-22T11:47:01+00:00 (RFC 3339) 1574423221000 (Unix Timestamp) |
| type        | Yes      | Type of test item. Allowable values: "suite", "story", "test", "scenario", "step", "before_class", "before_groups", "before_method", "before_suite",      "before_test", "after_class", "after_groups", "after_method", "after_suite", "after_test" | -              | suite                                                                                                                                                                |
| launchUuid  | Yes      | Parent launch UUID                                                                                                                                                                                                                                  | -              | 96d1bc02-6a3f-451e-b706-719149d51ce4                                                                                                                                 |
| description | No       | Test item description                                                                                                                                                                                                                               | empty          | Tests of loggers                                                                                                                                                     |
| attributes  | No       | Test item attributes(tags). Pairs of key and value                                                                                                                                                                                                  | empty          | most failed os:android                                                                                                                                               |
| uuid        | No       | Test item UUID                                                                                                                                                                                                                                      | auto generated | e9ca837e-966c-412e-bf8b-e879510d99d5                                                                                                                                 |
| codeRef     | No       | Physical location of test item                                                                                                                                                                                                                      | empty          | com.rpproject.tests.LoggingTests                                                                                                                                     |
| parameters  | No       | Set of parameters (for parametrized tests)                                                                                                                                                                                                          | empty          | logger:logback                                                                                                                                                       |
| uniqueId    | No       |                                                                                                                                                                                                                                                     | auto generated | auto:cd5a6c616d412b6739738951c922377f                                                                                                                                |
| retry       | No       | Used to report retry of test. Allowable values: 'true' or 'false'                                                                                                                                                                                   | false          | false                                                                                                                                                                |
| hasStats    | No       |                                                                                                                                                                                                                                                     | true           | true                                                                                                                                                                 |

Start test item response contains the following attributes:

| Attribute | Required | Example                              |
|-----------|----------|--------------------------------------|
| id        | Yes      | 7189ec02-4c36-4e36-9f90-5a9b31dcbdba |

So full request to start suite test looks like

 ```shell script
curl --header "Content-Type: application/json" \
     --header "Authorization: Bearer 039eda00-b397-4a6b-bab1-b1a9a90376d1" \
     --request POST \
     --data 'body' \
     http://rp.com/api/v1/rp_project/item
```

Where body is the following json:

```json
{
  "name": "Services",
  "startTime": "1574423234000",
  "type": "suite",
  "launchUuid": "96d1bc02-6a3f-451e-b706-719149d51ce4",
  "description": "Services tests"
}
```

And in the response we get `id` of created test item:

```json
{
  "id": "1e183148-c79f-493a-a615-2c9a888cb441"
}
```

Also we should save it to report child items under this one

## Start child(container) item

Next test item will be child for suite test item and it also will be parent for few step items.
It will be container item.
To start child item we need know launch UUID and parent test item UUID.
We should call the following endpoint:
POST `/api/{version}/{projectName}/item/{parentItemUuid}`

Request and response model the same as for parent item.

Full request:

```shell script
curl --header "Content-Type: application/json" \
     --header "Authorization: Bearer 039eda00-b397-4a6b-bab1-b1a9a90376d1" \
     --request POST \
     --data 'body' \
     http://rp.com/api/v1/rp_project/item/1e183148-c79f-493a-a615-2c9a888cb441
```

Where body is:

```json
{
  "name": "PluginServiceTest",
  "startTime": "1574423236000",
  "type": "test",
  "launchUuid": "96d1bc02-6a3f-451e-b706-719149d51ce4",
  "description": "Plugin tests"
}
```

And we have a response:

```json
{
  "id": "bb237b98-22b0-4289-9490-9bb29215fe5e"
}
```

## Start step item

Now we are going to start another final test item in our structure.

```shell script
curl --header "Content-Type: application/json" \
     --header "Authorization: Bearer 039eda00-b397-4a6b-bab1-b1a9a90376d1" \
     --request POST \
     --data 'body' \
     http://rp.com/api/v1/rp_project/item/bb237b98-22b0-4289-9490-9bb29215fe5e
```

With body:

```json
{
  "name": "uploadPlugin",
  "startTime": "1574423237000",
  "type": "step",
  "launchUuid": "96d1bc02-6a3f-451e-b706-719149d51ce4",
  "description": "Uploading plugin"
}
```

And response:

```json
{
  "id": "22e55c62-d028-4b49-840f-195d7a48b114"
}
```

## Finish child item

We are not going to report more test items under this one, so we can finish it.
To do that we should send the following request:
PUT `/api/{version}/{projectName}/item/{itemUuid}`

Finish test item request model:

| Attribute   | Required | Description                                                                                               | Default value | Example                                                                                                                                                              |
|-------------|----------|-----------------------------------------------------------------------------------------------------------|---------------|----------------------------------------------------------------------------------------------------------------------------------------------------------------------|
| endTime     | Yes      | Test item end time                                                                                        | -             | 2019-11-22T11:47:01+00:00 (ISO 8601) Fri, 22 Nov 2019 11:47:01 +0000 (RFC 822, 1036, 1123, 2822) 2019-11-22T11:47:01+00:00 (RFC 3339) 1574423221000 (Unix Timestamp) |
| launchUuid  | Yes      | Parent launch UUID                                                                                        | -             | 48ecc273-032f-44d4-822a-66e494e9b1e8                                                                                                                                 |
| status      | No       | Test item status. Allowable values: "passed", "failed", "stopped", "skipped", "interrupted", "cancelled". | -             | failed                                                                                                                                                               |
| description | No       | Test item description. Overrides description from start request.                                          | empty         | Test item description on finish                                                                                                                                      |
| attributes  | No       | Test item attributes(tags). Pairs of key and value                                                        | empty         | most failed os:android                                                                                                                                               |
| retry       | No       | Used to report retry of test. Allowable values: 'true' or 'false'                                         | false         | false                                                                                                                                                                |
| issue       | No       | Issue of current test item                                                                                | empty         | Will be described below in separate table                                                                                                                            |

Issue part for finish test item model:

| Attribute            | Required | Description                                                                                                 | Default value | Example                                   |
|----------------------|----------|-------------------------------------------------------------------------------------------------------------|---------------|-------------------------------------------|
| issueType            | Yes      | Issue type locator. Allowable values: "pb***", "ab***", "si***", "ti***", "nd001". Where *** is locator id. | -             | pb001                                     |
| comment              | No       | Issue commnet                                                                                               | empty         | Framework issue. Script outdated          |
| autoAnalyzed         | No       | Is issue was submitted by auto analyzer                                                                     | false         | false                                     |
| ignoreAnalyzer       | No       | Is issue should be ignored during auto analysis                                                             | false         | false                                     |
| externalSystemIssues | No       | Set of external system issues                                                                               | empty         | Will be described in separate table below |

External system issue: 

| Attribute  | Required | Description                            | Default value | Example                     |
|------------|----------|----------------------------------------|---------------|-----------------------------|
| ticketId   | No       | Id of ticket in external system        | empty         | ABCD1234                    |
| submitDate | No       | Ticket submit date as timestamp        | empty         | 1574696194000               |
| brsUrl     | No       | URL of external system                 | empty         | http://example.com          |
| btsProject | No       | Project name in external system        | empty         | ABCD                        |
| url        | No       | URL of ticket in external system issue | empty         | http://example.com/ABCD1234 |

If item finished successfully in the response will be message with item uuid.

Full request:

 ```shell script
curl --header "Content-Type: application/json" \
     --header "Authorization: Bearer 039eda00-b397-4a6b-bab1-b1a9a90376d1" \
     --request PUT \
     --data 'body' \
     http://rp.com/api/v1/rp_project/item/22e55c62-d028-4b49-840f-195d7a48b114
```

With body: 

```json
{
  "endTime": "1574423239000",
  "status": "failed",
  "launchUuid": "96d1bc02-6a3f-451e-b706-719149d51ce4",
  "issue": {
    "issueType": "pb001",
    "comment": "Some critical issue"    
  }
}
```

We can report other child items (`updatePlugin`, `removePlugin`) the same way as described above.

## Finish parent(container) item

After that we should finish their parent item.
We can do it the same way as for child items.

```shell script
curl --header "Content-Type: application/json" \
     --header "Authorization: Bearer 039eda00-b397-4a6b-bab1-b1a9a90376d1" \
     --request PUT \
     --data 'body' \
     http://rp.com/api/v1/rp_project/item/bb237b98-22b0-4289-9490-9bb29215fe5e
```

With body: 

```json
{
  "endTime": "1574423241000",
  "launchUuid": "96d1bc02-6a3f-451e-b706-719149d51ce4"
}
```

## Save log without attachment

We can save logs for test items.
For example let's try to save log for `uploadPlugin` test item.
It is not necessary to save log when test item already finished.
We can create log for test item with `in_progress` status.

Common endpoint: POST `/api/{version}/{projectName}/log`

And it has the following request model:

| Attribute  | Required | Description                                                                                                                  | Default value | Example                                                                                                                                                                |
|------------|----------|------------------------------------------------------------------------------------------------------------------------------|---------------|------------------------------------------------------------------------------------------------------------------------------------------------------------------------|
| launchUuid | Yes      | Launch UUID                                                                                                                  | -             | e80b62e1-b297-47a0-be22-5a4a25920c0a                                                                                                                                   |
| time       | Yes      | Log time                                                                                                                     | -             | 2019-11-22T11:47:01+00:00 (ISO 8601) Fri, 22 Nov 2019 11:47:01 +0000 (RFC 822, 1036, 1123, 2822)  2019-11-22T11:47:01+00:00 (RFC 3339)  1574423221000 (Unix Timestamp) |
| itemUuid   | No       | Test item UUID                                                                                                               | empty         | fb2a012f-5996-45a0-b3bb-d8210b4fb980                                                                                                                                   |
| message    | No       | Log message                                                                                                                  | empty         | [Forwarding findElement on session 477bee808ca0c415a7aae2de2edc5cc9 to remote] DEBUG o.a.h.c.protocol.RequestAddCookies - CookieSpec selected: default                 |
| level      | No       | Log level. Allowable values: error(40000), warn(30000), info(20000), debug(10000), trace(5000), fatal(50000), unknown(60000) | ?             | error                                                                                                                                                                  |

Response model: 

| Attribute | Required | Example                              |
|-----------|----------|--------------------------------------|
| id        | Yes      | 43f80000-7ca8-4fed-9da3-0759867a847c |

Full request:

```shell script
curl --header "Content-Type: application/json" \
     --header "Authorization: Bearer 039eda00-b397-4a6b-bab1-b1a9a90376d1" \
     --request POST \
     --data 'body' \
     http://rp.com/api/v1/rp_project/log
```

Where body is:

```json
{
  "launchUuid": "96d1bc02-6a3f-451e-b706-719149d51ce4",
  "itemUuid": "22e55c62-d028-4b49-840f-195d7a48b114",
  "time": "1574423245000",
  "message": "An error occurred while connecting to the server [Nested exception is java.lang.NoClassDefFoundError]",
  "level": "error"
}
```

## Batch save logs

It is convenient to send all logs with attachments using only one request.
Let's assume we want to save two logs with attachments (file1.pdf and file2.txt)

To the request model adds one more complex attribute `file` with the following parameters:

| Attribute   | Required | Description       | Default value | Example         |
|-------------|----------|-------------------|---------------|-----------------|
| name        | No       | File name         | -             | report.pdf      |
| content     | No       | Byte array        | -             | -               |
| contentType | No       | File content type | -             | application/pdf |

Response model contains an array of the following objects:

| Attribute  | Required | Description                               | Example                                                                                                                                                                                                                                                                                                                                                                 |
|------------|----------|-------------------------------------------|-------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------|
| id         | No       | UUID of created log                       | 77542c07-970c-481d-ad5a-b4ccd15ae178                                                                                                                                                                                                                                                                                                                                    |
| message    | No       | Exception message if error occurrs        | ReportPortalException: Binary data cannot be saved. There is no request part or file with name lin_av.png                                                                                                                                                                                                                                                               |
| stackTrace | No       | Stack trace of exception if error occurrs | com.epam.ta.reportportal.exception.ReportPortalException: Binary data cannot be saved. There is no request part or file with name lin_av.png\r\n\tat com.epam.ta.reportportal.commons.validation.ErrorTypeBasedRuleValidator.verify(ErrorTypeBasedRuleValidator.java:37)\r\n\tat com.epam.ta.reportportal.ws.controller.LogController.createLog(LogController.java:133) |

Full request:

```shell script
curl --header "Content-Type: application/json" \
     --header "Authorization: Bearer 039eda00-b397-4a6b-bab1-b1a9a90376d1" \
     --request POST \
     --form 'body' \
     --form "file=@/path/to/file1.pdf" \
     --form "file=@/path/to/file2.txt" \
     http://rp.com/api/v1/rp_project/log
```

With json body:

```json
[
  {
    "itemUuid": "9c7632a2-272e-4c24-9627-d7d509de7620",
	"launchUuid": "96d1bc02-6a3f-451e-b706-719149d51ce4",
	"time": "2019-11-06T15:50:53.187Z",
	"message": "Some critical exception",
	"level": 40000,
	"file": {
	  "name": "file1.pdf"
	}
  },
  {
	"itemUuid": "16fb3d7f-ddce-407a-8e52-464a596e6da1",
	"launchUuid": "96d1bc02-6a3f-451e-b706-719149d51ce4",
	"time": "2019-11-06T15:50:53.187Z",
	"message": "java.lang.NullPointerException",
	"level": 40000,
	"file": {
	  "name": "file2.txt"
	}
  }	
]
```

So we successfully reported logs with file attachments and can see in response:

```json
{
  "responses": [
    {
      "id": "ec1b0153-a00e-4c61-b6bf-ac0578c2ed43"
    },
    {
      "id": "b7661cb6-7e1a-40e2-8b96-59de41aa96e8"
    }
  ]
}
```

## Save launch log

It is possible to report log to launch.
To do that use the same log endpoint, but in body do not send `itemUuid`

```json
{
  "launchUuid": "96d1bc02-6a3f-451e-b706-719149d51ce4",
  "time": "2019-11-06T15:50:53.187Z",
  "message": "java.lang.NullPointerException",
  "level": 40000,
  "file": {
    "name": "file2.txt"
  }
}
```





















