import boto3
import os


def lambda_handler(event, context):
    LAMBDASNSTOPIC = os.environ["SNS_TOPIC_ARN"]
    SUPPRESS_STATES = os.environ["SUPPRESS_STATES"].split(",")
    region = "eu-central-1"
    # Create an MSK client
    client = boto3.client("kafka", region_name=region)
    # Retrieve a list of clusters
    response = client.list_clusters_v2()
    # Extract the cluster ARNs from the response
    cluster_arns = response["ClusterInfoList"]

    valid_states = ["ACTIVE"] + SUPPRESS_STATES
    print(
        "Notifications suppressed for these MSK states: {}".format(
            ", ".join(valid_states)
        )
    )

    for cluster in cluster_arns:
        arn = cluster["ClusterArn"]
        response = client.describe_cluster_v2(ClusterArn=arn)
        status = response["ClusterInfo"]["State"]
        print("The cluster {} is in state {}.".format(arn,status))
        sns_client = boto3.client("sns")
        if status not in valid_states:
            print("The MSK cluster: {} needs attention.".format(arn))
            sns_client.publish(
                TopicArn=LAMBDASNSTOPIC,
                Message="MSK cluster: "
                + arn
                + " needs attention. The status is: "
                + status,
                Subject="MSK Health Warning!",
            )
        else:
            print(
                "The MSK cluster: {} is in a healthy state, and is reachable and available for use.".format(
                    arn
                )
            )

    # Return the status
    return {"statusCode": 200, "body": "OK"}
