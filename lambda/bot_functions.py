import boto3

def get_param_map(param_root):
    client = boto3.client('ssm')
    response = client.describe_parameters(Filters=[{'Key': 'Name','Values': [param_root,],},])

    if not response['Parameters']:
        print('No such parameter root - ' + param_root)
        return {}

    name_list = []
    for p in response['Parameters']:
        if p['Name']:
            name_list.append(param_root + "/"+ p['Name'])

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
            response = client.put_parameter(
                Name=full_name,
                Value=value,
                Type='String',
                Overwrite=True
            )
        return 0
    except:
        print ('Error writing map to SSM parameter store' + kp_map)
        return 1