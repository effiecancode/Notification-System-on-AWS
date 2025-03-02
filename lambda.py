# notificationHandler

import boto3
import os
import json
import uuid
import datetime

# Initialize AWS clients
ses_client = boto3.client("ses", region_name="eu-west-2")
sns_client = boto3.client("sns", region_name="eu-west-2")
dynamodb = boto3.resource('dynamodb')

# Load environment variables
#SES_SENDER_EMAIL = os.getenv("SES_SENDER_EMAIL")
SES_SENDER_EMAIL = "faitheffie25@gmail.com"
# DYNAMODB_TABLE = os.getenv("DYNAMODB_TABLE")
DYNAMODB_TABLE = "NotificationsTable"
SNS_PLATFORM_APPLICATION_ARN = os.getenv("SNS_PLATFORM_APPLICATION_ARN")  # SNS push notification ARN

# Function to send email using SES
def send_email(recipient, subject, body):
    response = ses_client.send_email(
        Source=SES_SENDER_EMAIL,
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

# Function to send SMS using SNS
# def send_sms(phone_number, message):
#     response = sns_client.publish(
#         PhoneNumber=phone_number,
#         Message=message
#     )
#     return response["MessageId"]



# Function to send push notifications using SNS
def send_push_notification(device_token, message):
    # Construct payload
    payload = {
        "default": message,  # Used for SMS fallback
        "APNS": json.dumps({"aps": {"alert": message}}),  # Apple
        "GCM": json.dumps({"data": {"message": message}})  # Android (FCM)
    }

    response = sns_client.publish(
        TargetArn=device_token,  # Registered SNS device token ARN
        Message=json.dumps(payload),
        MessageStructure="json"
    )
    return response["MessageId"]

# Function to send SMS using SNS
def send_sms(phone_number, message):
    response = sns_client.publish(
        PhoneNumber=phone_number,
        Message=message
    )
    return response["MessageId"]

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

# Function to store notification metadata in DynamoDB

# DYNAMODB_TABLE = os.getenv("DYNAMODB_TABLE")
DYNAMODB_TABLE = "NotificationsTable"

def store_notification_metadata(notification_id, recipient, channel, status):
    table = dynamodb.Table(DYNAMODB_TABLE)
    timestamp = datetime.datetime.utcnow().isoformat()

    table.put_item(
        Item={
            'notification_id': notification_id,
            'recipient': recipient,
            'channel': channel,
            'status': status,
            'timestamp': timestamp
        }
    )

# lambda main entry
def lambda_handler(event, context):
    notification_id = str(uuid.uuid4())  # Unique ID for tracking
    channel = event.get("channel")  # Can be 'email', 'sms', or 'push'
    recipient = event.get("recipient")  # Email
    phone_number = event.get("phone_number")
    message = event.get("message", "Default notification message")
    subject = event.get("subject", "Notification Alert")
    try:
        if channel == "email":
            message_id = send_email(recipient, subject, message)
            status = "Email Sent"
        elif channel == "sms":
            message_id = send_sms(phone_number, message)
            status = "SMS Sent"
        elif channel == "push":
            message_id = send_push_notification(recipient, message)
            status = "Push Sent"
        else:
            return {"statusCode": 400, "body": json.dumps({"error": "Invalid notification channel"})}

        # Store notification metadata
        store_notification_metadata(notification_id, recipient, channel, status)

        return {
            "statusCode": 200,
            "body": json.dumps({
                "message": message,
                "id": notification_id,
                "message_id": message_id,
                "recipient": recipient,
                "channel": channel,
                "status": status,
            })
        }

    except Exception as e:
        return {
            "statusCode": 500,
            "body": json.dumps({"error": str(e)})
        }

def store_notification_metadata(notification_id, recipient, channel, status):
    """Store notification metadata in DynamoDB"""
    table = dynamodb.Table(DYNAMODB_TABLE)
    item = {
        "id": notification_id,
        "recipient": recipient,
        "channel": channel,
        "status": status
    }

    table.put_item(Item=item)
