import boto3
from botocore.exceptions import ClientError, BotoCoreError

def get_param_map(param_root):
    client = boto3.client('ssm')
    response = client.describe_parameters(Filters=[{'Key': 'Name','Values': [param_root,],},])

    if not response['Parameters']:
        print('No such parameter root - ' + param_root)
        return {}

    name_list = []
    for p in response['Parameters']:
        if p['Name']:
            # p['Name'] already contains the full parameter name returned by SSM
            name_list.append(p['Name'])

    if not name_list:
        print('No parameters at - ' + param_root)
        return {}

    response = client.get_parameters(Names=name_list)
    kp = {}
    for r in response['Parameters']:
        kp[r['Name']] = r['Value']
    
    return kp


def put_param_map(param_root, kp_map):
    client = boto3.client('ssm')
    try:
        for name, value in kp_map.items():
            full_name = param_root + name
            client.put_parameter(
                Name=full_name,
                Value=value,
                Type='String',
                Overwrite=True
            )
        return 0
    except (ClientError, BotoCoreError) as e:
        print(f'Error writing map to SSM parameter store: {kp_map}, error: {str(e)}')
        return 1