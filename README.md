# Serverless Notification-System-on-AWS
## Event-Driven Architecture
Cloud native Notification system running on AWS: Sends notifications to end-users through SMS,Push Notifications and Email.

## Design Overview:

* Event-Driven Architecture using Amazon EventBridge or AWS SNS for decoupling notification requests from services.
* API Gateway to receive a request
* AWS Lambda to process and deliver notifications to different channels (Email, SMS, Push).
* Amazon SES for Email, Amazon SNS for SMS and Push Notifications.
* DynamoDB for message tracking and logging notification status.
* Amazon SQS for handling retries and failed deliveries asynchronously.

## Logic
* API Gateway receives a request from a service.
* AWS Lambda Notification Processor reads the request and determines the target channel(s).
* Logic in Lambda:
    * If Email, invoke Amazon SES.
    * If SMS, invoke Amazon SNS (SMS).
    * If Push, publish to Amazon SNS (Push Topic).
* Message Status is logged in DynamoDB.
* If the message fails, it is sent to an SQS Dead-Letter Queue (DLQ) for retry processing.
* CloudWatch logs and X-Ray traces capture events.
* IAM roles for permissions and security

## Benefits of This Approach

✅ Scalability – AWS services handle millions of notifications efficiently.
✅ Cost Optimization – Pay-as-you-go pricing with SES, SNS, and Lambda.
✅ Resilience – Retries and dead-letter queues prevent message loss.
✅ Minimal Ops Overhead – No servers to manage, just configure services.
