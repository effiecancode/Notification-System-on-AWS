# notificationHandler

import boto3
import os
import uuid
from time import datetime
import json

ses_client = boto3.client("ses", region_name="eu-west-2")
dynamodb = boto3.resource('dynamodb')

# Notification Table References
metadata_table = dynamodb.Table('NotificationMetadata')
delivery_table = dynamodb.Table('DeliveryStatus')
status_table = dynamodb.Table('NotificationStatus')


def notificationHandler(event, context):
    # handle sending email using SES
    recipient = event.get("recipient", "user@example.com")
    subject = "Notification Alert"
    body = "This is an automated email from your AWS Lambda function."

    response = ses_client.send_email(
        Source=os.getenv("SES_SENDER_EMAIL"),
        Destination={"ToAddresses": [recipient]},
        Message={
            "Subject": {"Data": subject},
            "Body": {"Text": {"Data": body}}
        }
    )

    return {
        "statusCode": 200,
        "body": f"Email sent! Message ID: {response['MessageId']}"
        # json.dumps({"message": "Email sent!", "MessageId": response["MessageId"]})
    }

# SNS dynamodb ineraction pattern - Updates SNS notification delivery status in DynamoDB.
def handle_sns_delivery_status(notification_id, status):
    table = dynamodb.Table('NotificationStatus')

    table.update_item(
        Key={'notification_id': notification_id},
        UpdateExpression='SET #status = :status, #last_updated = :now',
        ExpressionAttributeNames={
            '#status': 'status',
            '#last_updated': 'last_updated'
        },
        ExpressionAttributeValues={
            ':status': status,
            ':now': datetime.datetime.utcnow()
        }
    )

# SES DynamoDB interaction pattern
def store_email_delivery_status(notification_id, delivery_info):

    timestamp = datetime.datetime.utcnow().isoformat()

    # Ensure delivery_info is a dictionary
    delivery_status = delivery_info.get("status", "UNKNOWN")
    recipient = delivery_info.get("recipient", "N/A")
    error_details = delivery_info.get("error_details", None)

    # First, update notification metadata
    metadata_table = dynamodb.Table('NotificationMetadata')
    metadata_table.put_item(
        Item={
            'notification_id': notification_id,
            'channel': 'SES',
            'status': delivery_status,
            'created_at': timestamp,
            'last_updated': timestamp
        }
    )

    # Then, store delivery status
    delivery_table = dynamodb.Table('DeliveryStatus')
    delivery_table.put_item(
        Item={
            'notification_id': notification_id,
            'recipient': recipient,
            'delivery_status': delivery_status,
            'delivery_timestamp': timestamp,
            'retry_count': 0,
            'error_details': error_details
        }
    )

"""
This architecture ensures:

    Real-time tracking of notification delivery status
    Historical data for analytics and debugging
    Consistent data structure across all notification channels
    High availability and scalability for storage operations
    Efficient querying and retrieval of notification data
"""

# lambda entry point - logs metadata in dynamodb
def lambda_handler(event, context):
    request_id = str(uuid.uuid4())
    timestamp = datetime.datetime.utcnow().isoformat()

    # Example metadata
    metadata = {
        "id": request_id,
        "timestamp": timestamp,
        "event_source": event.get("source", "unknown"),
        "message": "Lambda executed successfully"
    }

    # Store metadata in DynamoDB
    metadata_table.put_item(Item=metadata)

    return {
        "statusCode": 200,
        "body": json.dumps({
            "message": "Metadata logged successfully",
            "metadata": metadata
        })
    }