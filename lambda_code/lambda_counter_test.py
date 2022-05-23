import boto3
import pytest
from moto import mock_dynamodb2
from lambda_function import *


@mock_dynamodb2
def test_lambda_handler():

    table_name = 'test_counter'
    dynamodb = boto3.resource('dynamodb', 'us-east-1')

    table = dynamodb.create_table(
        TableName=table_name,
        KeySchema=[{'AttributeName': 'user_id', 'KeyType': 'HASH'}],
        AttributeDefinitions=[{'AttributeName': 'user_id','AttributeType': 'S'}],
        ProvisionedThroughput={'ReadCapacityUnits': 5, 'WriteCapacityUnits': 5}
    )

    response = lambda_handler(event=kinesis_test_event, context={})

    table = dynamodb.Table(table_name)
    response = table.get_item(
        Key={
            'stat': {'S': 'view-count'}
        }
    )
    
    item = response['view-count']