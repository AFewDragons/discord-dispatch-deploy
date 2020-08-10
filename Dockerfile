# Container image that runs your code
FROM debian:9.5

WORKDIR /
ADD Dispatch/ ./Dispatch/
RUN chmod -R +x ./Dispatch/
ADD entrypoint.sh /entrypoint.sh

# Code file to execute when the docker container starts up (`entrypoint.sh`)
ENTRYPOINT ["/entrypoint.sh"]