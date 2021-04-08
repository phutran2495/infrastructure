import boto3
import json
ses_client = boto3.client('ses')
db_resource = boto3.resource('dynamodb')
table = db_resource.Table('message_notification')

def notifyuser(event, context):
    event = json.loads(event["Records"][0]['Sns']['Message'])
    recipient = event['recipient']
    message = event['message']
   
    print(recipient)
    print(message)
    status = get_record(message)
    print(status)
    if not status:
        ses_response = ses_client.send_email(
            Source='tranphu@prod.phutran.me',
            Destination={
                'ToAddresses': [
                    recipient
                ]
            },
            Message={
                'Subject': {
                    'Data': 'Your book has been changed' 
                },
                'Body': {
                    'Text': {
                        'Data': message 
                        
                    }
                }
            }
        )
        insert_record(message)
        return "notify the user succesfully"
    else:
        return " duplicate message"



def insert_record(message_content):
    response = table.put_item(
        Item={
            "message":message_content
        }
    )
    return response["ResponseMetadata"]["HTTPStatusCode"]


def get_record(message_content):
    response = table.get_item(
        Key={
            "message": message_content
        }
    )
    if 'Item' in response:
        return "There is an item found "
    else:
        return ""