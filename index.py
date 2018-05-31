"""
Slack chat-bot Lambda handler.
"""

import os
import logging
import urllib
import boto3
import operator
from datetime import datetime

# Grab the Bot OAuth token from the environment.
BOT_TOKEN = os.environ["BOT_TOKEN"]
BOT_VERSION = os.environ["BOT_VERSION"]
PARAMETER_PATH = "/slack_bot/" + BOT_TOKEN

# Define the URL of the targeted Slack API resource.
# We'll send our replies there.
SLACK_URL = "https://slack.com/api/chat.postMessage"


def lambda_handler(data, context):
    """Handle an incoming HTTP request from a Slack chat-bot.
    """
    logger = logging.getLogger(__name__)
    logger.addHandler(logging.StreamHandler())
    logger.setLevel(logging.INFO)

    # get SSM client
    client = boto3.client('ssm')

    #confirm  parameter exists before updating it
    response = client.describe_parameters(Filters=[{'Key': 'Name','Values': [PARAMETER_PATH,],},])
    logger.info(PARAMETER_PATH)

    if "challenge" in data:
        if not response['Parameters']:
            print('No such parameter - creating')
        response = client.put_parameter(
          Name=PARAMETER_PATH,
          Value=data["token"],
          Type='String',
          Overwrite=True
        )
        logger.info(data)
        return data["challenge"]

    # Grab the Slack event data.
    slack_event = data['event']
    logger.info(data)
    logger.info(response)
    if not response['Parameters']:
        print('No such parameter')
        return 'SSM parameter not found.'
    
    response = client.get_parameters(Names=[PARAMETER_PATH,])
    # We need to discriminate between events generated by 
    # the users, which we want to process and handle, 
    # and those generated by the bot.
    if "bot_id" in slack_event:
        logger.warn("Ignore bot event")
    elif response['Parameters'][0]['Value'] != data['token']:
    	  logger.warn("Ignore - not our slack event")
    else:
        # Get the text of the message the user sent to the bot,
        # and reverse it.
        text = slack_event["text"]
        reversed_text = text[::-1]
        
        # Get the ID of the channel where the message was posted.
        channel_id = slack_event["channel"]
        
        # We need to send back three pieces of information:
        #     1. The reversed text (text)
        #     2. The channel id of the private, direct chat (channel)
        #     3. The OAuth token required to communicate with 
        #        the API (token)
        # Then, create an associative array and URL-encode it, 
        # since the Slack API doesn't not handle JSON (bummer).
        data = urllib.parse.urlencode(
            (
                ("token", BOT_TOKEN),
                ("channel", channel_id),
                ("text", reversed_text)
            )
        )
        data = data.encode("ascii")
        
        # Construct the HTTP request that will be sent to the Slack API.
        request = urllib.request.Request(
            SLACK_URL, 
            data=data, 
            method="POST"
        )
        # Add a header mentioning that the text is URL-encoded.
        request.add_header(
            "Content-Type", 
            "application/x-www-form-urlencoded"
        )
        
        # Fire off the request!
        urllib.request.urlopen(request).read()

    # Everything went fine.
    return "200 OK"