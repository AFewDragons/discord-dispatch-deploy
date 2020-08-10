# Container image that runs your code
FROM alpine:3.10

COPY Dispatch /Dispatch
RUN chmod -R +x /Dispatch
COPY entrypoint.sh /entrypoint.sh

# Code file to execute when the docker container starts up (`entrypoint.sh`)
ENTRYPOINT ["/entrypoint.sh"]