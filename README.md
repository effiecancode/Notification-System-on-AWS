# Notification-System-on-AWS
Cloud native Notification system running on AWS: Sends notifications to end-users through SMS,Push Notifications and Email.


## Handling Different Notification Channels (Email, SMS, Push Notifications)
The AWS Notification Platform is designed to dynamically handle multiple notification channels while ensuring reliability, scalability, and cost-efficiency. The system follows an event-driven architecture where notification requests are processed and routed to the appropriate channels (Email, SMS, Push) based on message type and user preferences.

## How routing to the different channels work
API Gateway receives a request from a service.
AWS Lambda Notification Processor reads the request and determines the target channel(s).
Routing Logic in Lambda:

    If Email, invoke Amazon SES.
    If SMS, invoke Amazon SNS (SMS).
    If Push, publish to Amazon SNS (Push Topic).

* Message Status is logged in DynamoDB. If the message fails, it is sent to an SQS Dead-Letter Queue (DLQ) for retry processing.


## How API Gateway + Lambda works

1️⃣ Client (Mobile/Web App) sends an HTTP request (e.g., POST /send-notification).
2️⃣ API Gateway receives the request, applies authentication, validation, and rate limiting.
3️⃣ API Gateway triggers Lambda, passing the request body as an event.
4️⃣ Lambda processes the request (email, SMS, or push notification).
5️⃣ Lambda returns a response to API Gateway.
6️⃣ API Gateway forwards the response back to the client.


## Benefits of This Approach

✅ Scalability – AWS services handle millions of notifications efficiently.
✅ Cost Optimization – Pay-as-you-go pricing with SES, SNS, and Lambda.
✅ Resilience – Retries and dead-letter queues prevent message loss.
✅ Minimal Ops Overhead – No servers to manage, just configure services.