import boto3
import os

def lambda_handler(event, context):
    LAMBDASNSTOPIC = os.environ['SNS_TOPIC_ARN']
    region = 'eu-central-1'
    # Create an MSK client
    client = boto3.client('kafka', region_name=region)
    # Retrieve a list of clusters
    response = client.list_clusters()
    # Extract the cluster ARNs from the response
    cluster_arns = response['ClusterInfoList']

    for cluster in cluster_arns:
        arn = cluster['ClusterArn']
        response = client.describe_cluster(ClusterArn=arn)
        status = response['ClusterInfo']['State']
        sns_client = boto3.client('sns')

        if status != 'ACTIVE':
          print("The MSK cluster: {} needs attention.".format(arn))
          sns_client.publish(TopicArn=LAMBDASNSTOPIC,
                           Message="MSK cluster: " + arn + " needs attention. The status is: " + status,
                           Subject="MSK Health Warning!")
        else:
          print(
            "The MSK cluster: {} is in a healthy state, and is reachable and available for use.".format(
                arn))

    # Return the status
    return {
        'statusCode': 200,
        'body': 'OK'
    }

if __name__ == '__main__':
    lambda_handler(None, None)
