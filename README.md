# How to create a lambda application
Follow the below instruction set for initiate, test and deploy

## Install some dependent cli

```bash
brew install aws-sam-cli
brew install awscli
brew install awscli-local
```

Execute and following command to create a template project
```bash
sam init -r java11
```

I have used sam version [SAM CLI, version 1.111.0]
You will get similar response after completing your choice from the command menu

Project name [sam-app]: lambda-stack

    -----------------------
    Generating application:
    -----------------------
    Name: lambda-stack
    Runtime: java11
    Architectures: x86_64
    Dependency Manager: maven
    Application Template: hello-world
    Output Directory: .
    Configuration file: lambda-stack/samconfig.toml
    
    Next steps can be found in the README file at lambda-stack/README.md

## Use the SAM CLI to build and test locally

Build your application with the `sam build` command.

```bash
sam build
```

The SAM CLI installs dependencies defined in `HelloWorldFunction/pom.xml`, creates a deployment package, and saves it in the `.aws-sam/build` folder.

Test a single function by invoking it directly with a test event. An event is a JSON document that represents the input that the function receives from the event source. Test events are included in the `events` folder in this project.

Run functions locally and invoke them with the `sam local invoke` command.

```bash
sam local invoke HelloWorldFunction --event events/event.json
```

You can pass parameters with parameter-overrides flag and those params will override cloud formation variables, for example
```bash
sam local invoke DynamicContentTemplateUploaderLambda -e events/event.json --parameter-overrides StagePrefix=local- Environment=test Team=dynamite
```

This will fail if you not run the localstack. For running the localstack you can create profiles and credentials for future usage. Your application may need those credentials and zone information.
Create a profile for localstack by executing the following command
```bash
aws configure --profile "localstack"
```
Or update your .aws/config with

    [profile localstack]
    region=us-east-1
    output=json
    endpoint_url = http://localhost:4566
and update your .aws/credentials with

    [localstack]
    aws_access_key_id=test
    aws_secret_access_key=test

To run localstack execute docker compose by 
```bash
docker compose up -d
```
now run the local invoke again and it will invoke and give you a response

The SAM CLI can also emulate your application's API. Use the `sam local start-api` to run the API locally on port 3000.

```bash
sam local start-api
curl http://localhost:3000/hello
```

The SAM CLI reads the application template to determine the API's routes and the functions that they invoke. The `Events` property on each function's definition includes the route and method for each path.

```yaml
      Events:
        HelloWorld:
          Type: Api
          Properties:
            Path: /hello
            Method: get
```

## How to debug from your Intellij IDE
Invoke lambda function and attach to a port and that port will receive the invoked event and will catch it from the ide. In intellij ide you have to select 'Remove JVM Debug' and update your port that you have invoked.
```bash
sam local invoke HelloWorldFunction  -e events/event.json -d 5858 
// here I have invoked to 5858 and I have to update 5858 in intellij ide to receive
// after executing this command now click on the debug button on the ide and it will go to the debugged point
```

You can also debug from the intellij ide by executing lambda function from the template file
When you execute first time you will be navigated to the run/debug configuration, you have to select the event/event.json as an input file and select profile as localstack from the aws connection tab

Install localstack desktop to check your lambda function alternately you can check from the browser too. Browser link https://app.localstack.cloud/. First time you have to create your account before navigate to resource.
```bash
brew install localstack/tap/localstack-cli
```

Execute the shell script to create zip file what you will deploy to your lambda in localstack
```bash
sh create_zip.sh
```

To check the list of lambda functions
```bash
aws --endpoint-url=http://127.0.0.1:4566 lambda list-functions
```
You can use awslocal instead of aws with endpoint because you have already configured the url for localstack
```bash
awslocal lambda list-functions
```
To create a lambda function in localstack write the following
```bash
awslocal lambda create-function --function-name HelloWorldFunction \
    --zip-file fileb://HelloWorldFunction.zip \
    --handler helloworld.App::handleRequest \
    --runtime java11 \
    --role arn:aws:iam::000000000000:role/basic-application \
    --timeout 900
```

To check created function details
```bash
awslocal lambda create-function-url-config \
--function-name HelloWorldFunction \
--auth-type NONE
```

Invoke lambda function and get results and store in a json file
```bash
awslocal lambda invoke --function-name HelloWorldFunction \
     --cli-binary-format raw-in-base64-out \
     --payload '{}' \
    result.json
```

## Add a resource to your application
The application template uses AWS Serverless Application Model (AWS SAM) to define application resources. AWS SAM is an extension of AWS CloudFormation with a simpler syntax for configuring common serverless application resources such as functions, triggers, and APIs. For resources not included in [the SAM specification](https://github.com/awslabs/serverless-application-model/blob/master/versions/2016-10-31.md), you can use standard [AWS CloudFormation](https://docs.aws.amazon.com/AWSCloudFormation/latest/UserGuide/aws-template-resource-type-ref.html) resource types.

## Fetch, tail, and filter Lambda function logs

To simplify troubleshooting, SAM CLI has a command called `sam logs`. `sam logs` lets you fetch logs generated by your deployed Lambda function from the command line. In addition to printing the logs on the terminal, this command has several nifty features to help you quickly find the bug.

`NOTE`: This command works for all AWS Lambda functions; not just the ones you deploy using SAM.

```bash
lambda-stack$ sam logs -n HelloWorldFunction --stack-name lambda-stack --tail
```

You can find more information and examples about filtering Lambda function logs in the [SAM CLI Documentation](https://docs.aws.amazon.com/serverless-application-model/latest/developerguide/serverless-sam-cli-logging.html).

## Unit tests

Tests are defined in the `HelloWorldFunction/src/test` folder in this project.

```bash
lambda-stack$ cd HelloWorldFunction
HelloWorldFunction$ mvn test
```

## Cleanup

To delete the sample application that you created, use the AWS CLI. Assuming you used your project name for the stack name, you can run the following:

```bash
sam delete --stack-name lambda-stack
```
