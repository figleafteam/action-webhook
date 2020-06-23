FROM alpine:latest

LABEL "name"="bash"
LABEL "repository"="https://github.com/figleafteam/action-webhook"
LABEL "version"="0.0.1"

LABEL com.github.actions.name="Figleaf Workflow Webhook"
LABEL com.github.actions.description="An action that will call a webhook from workflow"


RUN apk update && apk add --no-cache bash curl jq openssl xxd
COPY LICENSE  /
COPY entrypoint.sh /entrypoint.sh

RUN chmod +x /entrypoint.sh

ENTRYPOINT ["/entrypoint.sh"]
