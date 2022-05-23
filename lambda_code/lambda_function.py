import json, boto3

client = boto3.client('dynamodb')
TableName = 'cloud-resume-stats'

def lambda_handler(event, context):
    
    data = client.get_item(
        TableName='cloud-resume-stats',
        Key = {
            'stat': {'S': 'view-count'}
        }
    )
    
    response = client.update_item(
        TableName='cloud-resume-stats',
        Key = {
            'stat': {'S': 'view-count'}
        },
        UpdateExpression = 'ADD Quantity :inc',
        ExpressionAttributeValues = {":inc" : {"N": "1"}},
        ReturnValues = 'UPDATED_NEW'
        )
        
    value = response['Attributes']['Quantity']['N']
    
    return {
        "body": value,
        "headers": {
            "Content-Type": "application/json"
        }
    }