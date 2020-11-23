#!/bin/bash

set -e

if [ -z "$webhook_url" ]; then
    echo "No webhook_url configured"
    exit 1
fi

if [ -z "$webhook_secret" ]; then
    echo "No webhook_secret configured"
    exit 1
fi


CONTENT_TYPE="application/json"

WEBHOOK_DATA="{\"event\":\"$GITHUB_EVENT_NAME\",\"repository\":\"$GITHUB_REPOSITORY\",\"commit\":\"$GITHUB_SHA\",\"ref\":\"$GITHUB_REF\",\"head\":\"$GITHUB_HEAD_REF\",\"workflow\":\"$GITHUB_WORKFLOW\",\"sender\": {\"id\": 12345}}"

WEBHOOK_SIGNATURE=$(echo -n "$WEBHOOK_DATA" | openssl sha1 -hmac "$webhook_secret" -binary | xxd -p)
WEBHOOK_ENDPOINT=$webhook_url

curl -k -v --fail \
    -H "Content-Type: $CONTENT_TYPE" \
    -H "User-Agent: User-Agent: GitHub-Hookshot/760256b" \
    -H "X-Hub-Signature: sha1=$WEBHOOK_SIGNATURE" \
    -H "X-GitHub-Delivery: $GITHUB_RUN_NUMBER" \
    -H "X-GitHub-Event: $GITHUB_EVENT_NAME" \
    --data "$WEBHOOK_DATA" $WEBHOOK_ENDPOINT
