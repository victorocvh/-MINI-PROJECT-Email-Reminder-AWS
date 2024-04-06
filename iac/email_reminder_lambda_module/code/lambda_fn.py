import boto3, os, json 

FROM_EMAIL_ADDRESS = 'victor.ocv+sender@hotmail.com'

ses = boto3.client('ses')

def lambda_handler(event, context):
    print("Received event: " + json.dumps(event))

    ses.send_email(
        Source=FROM_EMAIL_ADDRESS,
        Destination={'ToAddresses': [event['Input']['email']]},
        Message={
            'Subject': {'Data': 'WhiskerCommands You to attend!'},
            'Body': {'Text': {'Data': event['input']['message']}}
        }
    )

    return 'Success!'
