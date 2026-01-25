import os
import logging
import json
# We use urllib.request instead of requests just to make the demo easier
# In a production environment, consider using the requests library
from urllib.request import Request, urlopen
from urllib.error import URLError, HTTPError
from botocore.exceptions import ClientError, BotoCoreError
from bot_functions import get_param_map

logger = logging.getLogger(__name__)
logger.addHandler(logging.StreamHandler())
logger.setLevel(logging.DEBUG)

PARAM_ROOT = os.environ.get('PARAM_ROOT')

# Initialize variables
FEEDBACK_CHANNEL = None
FEEDBACK_SLACK_NAME = None
FEEDBACK_SLACK_EMOJI = None
FEEDBACK_SLACK_URL = None

if PARAM_ROOT:
    try:
        kp = get_param_map(PARAM_ROOT)
        if kp:
            FEEDBACK_CHANNEL = kp.get('channel')
            FEEDBACK_SLACK_NAME = kp.get('slack_name')
            FEEDBACK_SLACK_EMOJI = kp.get('slack_emoji')
            FEEDBACK_SLACK_URL = kp.get('slack_url')
    except (ClientError, BotoCoreError) as e:
        logger.error(f'Error retrieving SSM parameters: {str(e)}')


def lambda_handler(event, context):
    ''' Receive SNS and send to Slack '''

    if context:
        logger.debug('Function ARN: %s', context.invoked_function_arn)
    else:
        logger.warning('Lambda context is missing')

    if not all([FEEDBACK_CHANNEL, FEEDBACK_SLACK_NAME, FEEDBACK_SLACK_EMOJI, FEEDBACK_SLACK_URL]):
        logger.error('No Slack Details are available.')
        return 'No Slack Details are available.'

    for record in event['Records']:
        if 'Sns' not in record:
            logger.warning('ERROR ABANDON RECORD:  Not an SNS event')
            continue

        subject = record['Sns']['Subject']

        if subject != 'feedback':
            logger.warning('Non-feedback message in feedback SNS')
            continue

        feedback = json.loads(record['Sns']['Message'])

        msgtext = '`%s` (%s) from `%s` (%s) says: ```%s```' % (feedback['user_name'], feedback['user_id'], feedback['team_domain'], feedback['team_id'], feedback['text'])

        slack_message = {
            'text' : msgtext,
            'mrkdwn': True,
            'channel': FEEDBACK_CHANNEL,
            'username': FEEDBACK_SLACK_NAME,
            'icon_emoji': FEEDBACK_SLACK_EMOJI
        }
        slack_url = FEEDBACK_SLACK_URL
        req = Request(slack_url, json.dumps(slack_message).encode('utf-8'))
        req.add_header('Content-Type', 'application/json')
        try:
            response = urlopen(req)
            response.read()
            logger.info('Message posted')
        except HTTPError as exc:
            logger.error('Request failed: %d %s', exc.code, exc.reason)
        except URLError as exc:
            logger.error('Server connection failed: %s', exc.reason)