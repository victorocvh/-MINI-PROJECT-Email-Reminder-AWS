import boto3
import json
import os
import decimal

SM_ARN = os.environ['state_machine_arn']

sm = boto3.client('stepfunctions')

def lambda_handler(event, context):
    print("Received event: " + json.dumps(event))

    if 'body' not in event:
        # Cria um evento personalizado com o corpo recebido
        event = {
            'body': json.dumps(event)
        }

    data = json.loads(event['body'])
    data['waitSeconds'] = int(data['waitSeconds'])

    if not all([
        'waitSeconds' in data,
        isinstance(data['waitSeconds'], int),
        'message' in data
    ]):
        return {
            'statusCode': 400,
            'headers': {
                'Access-Control-Allow-Origin': '*',
                'Access-Control-Allow-Methods': '*',
                'Access-Control-Allow-Headers': '*',
                'Access-Control-Allow-Credentials': True
            },
            'body': json.dumps({"Status": "Internal Server Error"})
        }

    try:
        sm.start_execution(stateMachineArn=SM_ARN, input=json.dumps(data, cls=DecimalEncoder))
        return {
            'statusCode': 200,
            'headers': {
                'Access-Control-Allow-Origin': '*',
                'Access-Control-Allow-Methods': '*',
                'Access-Control-Allow-Headers': '*',
                'Access-Control-Allow-Credentials': True
            },
            'body': json.dumps({"Status": "Success"})
        }
    except Exception as e:
        print("Error starting execution:", e)
        return {
            'statusCode': 500,
            'headers': {
                'Access-Control-Allow-Origin': '*',
                'Access-Control-Allow-Methods': '*',
                'Access-Control-Allow-Headers': '*',
                'Access-Control-Allow-Credentials': True
            },
            'body': '{"Status": "Internal Server Error"}'
        }

class DecimalEncoder(json.JSONEncoder):
    def default(self, obj):
        if isinstance(obj, decimal.Decimal):
            return int(obj)
        return super(DecimalEncoder, self).default(obj)
