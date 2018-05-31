import os
import logging
import json
# We use urllib2 instead of requests just to make the demo easier
# In a production environment, consider using the requests library
from urllib2 import Request, urlopen, URLError, HTTPError
from bot_functions import get_param_map put_param_map

logger = logging.getLogger(__name__)
logger.addHandler(logging.StreamHandler())
logger.setLevel(logging.DEBUG)

PARAM_ROOT = os.environ.get('PARAM_ROOT')

kp = get_param_map(PARAM_ROOT)

try:
	FEEDBACK_CHANNEL_PATH = kp['channel']
	FEEDBACK_SLACK_NAME_PATH = kp['slack_name']
	FEEDBACK_SLACK_EMOJI_PATH = kp['slack_emoji']
	FEEDBACK_SLACK_URL_PATH = kp['slack_url']
except:
	print('No Slack Details are available.')
	return 'No Slack Details are available.'


def lambda_handler(event, context):
    ''' Receive SNS and send to Slack '''

    if context:
        LOGGER.debug('Function ARN: %s', context.invoked_function_arn)
    else:
        LOGGER.warning('Lambda context is missing')

    for record in event['Records']:
        if 'Sns' not in record:
            LOGGER.warn('ERROR ABANDON RECORD:  Not an SNS event')
            continue

        subject = record['Sns']['Subject']

        if subject != 'feedback':
            LOGGER.warn('Non-feedback message in feedback SNS')
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
        req = Request(slack_url, json.dumps(slack_message))
        try:
            response = urlopen(req)
            response.read()
            LOGGER.info('Message posted')
        except HTTPError as exc:
            LOGGER.error('Request failed: %d %s', exc.code, exc.reason)
        except URLError as exc:
            LOGGER.error('Server connection failed: %s', exc.reason)