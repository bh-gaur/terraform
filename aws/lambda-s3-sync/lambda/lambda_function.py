import boto3
import urllib.parse

s3 = boto3.client('s3')

def lambda_handler(event, context):
    src_bucket = event['Records'][0]['s3']['bucket']['name']
    dst_bucket = 'destination-bucket-name'  # Set this in your env var
    key = urllib.parse.unquote_plus(event['Records'][0]['s3']['object']['key'])

    copy_source = {'Bucket': src_bucket, 'Key': key}
    s3.copy_object(Bucket=dst_bucket, CopySource=copy_source, Key=key)

    return {
        'statusCode': 200,
        'body': f'Copied {key} from {src_bucket} to {dst_bucket}'
    }
