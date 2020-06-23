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

DATA_JSON=$( jq -n \
                  --arg ghRepo "$GITHUB_REPOSITORY" \
                  --arg ghRef "$GITHUB_REF" \
                  --arg ghCommit "$GITHUB_SHA" \
                  --arg ghEvent "$GITHUB_EVENT_NAME" \
                  --arg ghWorkFlow "$GITHUB_WORKFLOW" '{repository: $ghRepo, ref: $ghRef, commit $ghCommit ,trigger: $ghEvent, workflow: $ghWorkFlow}')

if [ -n "$data" ]; then
    COMPACT_JSON=$(echo -n "$data" | jq -c '')
    WEBHOOK_DATA="{$DATA_JSON,\"data\":$COMPACT_JSON}"
else
    WEBHOOK_DATA="{$DATA_JSON}"
fi

WEBHOOK_SIGNATURE=$(echo -n "$WEBHOOK_DATA" | openssl sha1 -hmac "$webhook_secret" -binary | xxd -p)

WEBHOOK_ENDPOINT=$webhook_url
if [ -n "$webhook_auth" ]; then
    WEBHOOK_ENDPOINT="-u $webhook_auth $webhook_url"
fi

curl -X POST \ 
    -H "content-type: application/json" \
    -H "User-Agent: User-Agent: GitHub-Hookshot/760256b" \
    -H "x-hub-signature: sha1=$WEBHOOK_SIGNATURE" \
    -H "x-gitHub-delivery: $GITHUB_RUN_NUMBER" \
    -H "x-github-event: $GITHUB_EVENT_NAME" \
    --data "$WEBHOOK_DATA" $WEBHOOK_ENDPOINT


