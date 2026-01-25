"""SSM Parameter Store helper functions for Slack bot."""

from typing import Any

import boto3
from botocore.exceptions import BotoCoreError, ClientError


def get_param_map(param_root: str) -> dict[str, str]:
    """Retrieve parameters from SSM Parameter Store.

    Args:
        param_root: The parameter path prefix to search for.

    Returns:
        A dictionary mapping parameter names to their values.
    """
    client = boto3.client("ssm")
    describe_response = client.describe_parameters(
        Filters=[{"Key": "Name", "Values": [param_root]}]
    )

    if not describe_response["Parameters"]:
        print("No such parameter root - " + param_root)
        return {}

    # p['Name'] already contains the full parameter name returned by SSM
    name_list = [
        name for p in describe_response["Parameters"] if (name := p.get("Name"))
    ]

    if not name_list:
        print("No parameters at - " + param_root)
        return {}

    get_response = client.get_parameters(Names=name_list)
    kp: dict[str, str] = {}
    for r in get_response["Parameters"]:
        name = r.get("Name")
        value = r.get("Value")
        if name and value:
            kp[name] = value

    return kp


def put_param_map(param_root: str, kp_map: dict[str, Any]) -> int:
    """Write parameters to SSM Parameter Store.

    Args:
        param_root: The parameter path prefix.
        kp_map: A dictionary of parameter names to values.

    Returns:
        0 on success, 1 on failure.
    """
    client = boto3.client("ssm")
    try:
        for name, value in kp_map.items():
            full_name = param_root + name
            client.put_parameter(
                Name=full_name, Value=value, Type="String", Overwrite=True
            )
    except (ClientError, BotoCoreError) as e:
        print(f"Error writing map to SSM parameter store: {kp_map}, error: {e!s}")
        return 1
    else:
        return 0
