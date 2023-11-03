from typing import List

import boto3
import os

CLUSTER_ARNS: list[str] = os.environ["CLUSTER_ARNS"].split(",")
ENABLE_CLOUDWATCH_METRICS: str = os.environ["ENABLE_CLOUDWATCH_METRICS"]
ENABLE_SNS_NOTIFICATIONS: str = os.environ["ENABLE_SNS_NOTIFICATIONS"]
LAMBDASNSTOPIC: str = os.environ["SNS_TOPIC_ARN"]
SUPPRESS_STATES: list[str] = os.environ["SUPPRESS_STATES"].split(",")


def lambda_handler(event, context):
    region = "eu-central-1"

    # Create boto clients
    kafka = boto3.client("kafka", region_name=region)
    cloudwatch = boto3.client("cloudwatch")
    sns = boto3.client("sns")

    valid_states = ["ACTIVE"] + SUPPRESS_STATES
    print(
        "Notifications suppressed for these MSK states: {}".format(
            ", ".join(valid_states)
        )
    )

    for arn in CLUSTER_ARNS:
        try:
            response = kafka.describe_cluster_v2(ClusterArn=arn)
        except Exception as e:
            print(f"An error occurred when trying to describe the cluster {arn}: {e}")
            continue

        status = response["ClusterInfo"]["State"]
        cluster_name = response["ClusterInfo"]["ClusterName"]
        arn_parts = arn.split(":")
        account_id = arn_parts[4]
        print(
            "The cluster {} in account {} is in state {}.".format(
                cluster_name, account_id, status
            )
        )

        if status not in valid_states:
            print("The MSK cluster {} needs attention.".format(arn))
            if ENABLE_SNS_NOTIFICATIONS:
                sns.publish(
                    TopicArn=LAMBDASNSTOPIC,
                    Message="MSK cluster "
                    + cluster_name
                    + " needs attention. The status is "
                    + status,
                    Subject="MSK Health Warning!",
                )
            if ENABLE_CLOUDWATCH_METRICS:
                put_custom_metric(
                    cloudwatch=cloudwatch, cluster_name=cluster_name, value=1
                )
        else:
            print(
                "The MSK cluster {} is in a healthy state, and is reachable and available for use.".format(
                    arn
                )
            )
            if ENABLE_CLOUDWATCH_METRICS:
                put_custom_metric(
                    cloudwatch=cloudwatch, cluster_name=cluster_name, value=0
                )
    return {"statusCode": 200, "body": "OK"}


def put_custom_metric(cloudwatch, cluster_name: str, value: int):
    return cloudwatch.put_metric_data(
        MetricData=[
            {
                "MetricName": "Status",
                "Dimensions": [
                    {"Name": "ClusterName", "Value": cluster_name},
                ],
                "Unit": "None",
                "Value": value,
            },
        ],
        Namespace="Custom/Kafka",
    )
