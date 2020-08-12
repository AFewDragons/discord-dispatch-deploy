# Container image that runs your code
FROM ubuntu:20.04
RUN apt-get update
RUN apt-get install -y wget build-essential zlib1g-dev
ARG OPENSSL_VERSION=1.1.0g
ENV RUST_BACKTRACE=full
RUN wget https://www.openssl.org/source/openssl-${OPENSSL_VERSION}.tar.gz
RUN tar xvfz openssl-${OPENSSL_VERSION}.tar.gz
RUN cd openssl-${OPENSSL_VERSION} && ./config && make && make install_sw
RUN echo '/usr/local/lib' >> /etc/ld.so.conf
RUN cat /etc/ld.so.conf
RUN ldconfig
RUN echo 'export LD_LIBRARY_PATH=/usr/local/lib' >> ~/.bash_profile && . ~/.bash_profile
RUN openssl version

WORKDIR /
ADD Dispatch/ ./Dispatch/
RUN chmod -R +x ./Dispatch/
ADD entrypoint.sh /entrypoint.sh

# Code file to execute when the docker container starts up (`entrypoint.sh`)
ENTRYPOINT ["/entrypoint.sh"]