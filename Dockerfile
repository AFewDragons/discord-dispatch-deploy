FROM mcr.microsoft.com/powershell:7.1.0-preview.6-ubuntu-20.04

ENV \
    VERSION=1.1.0l \
    SHA256=74a2f756c64fd7386a29184dc0344f4831192d61dc2481a93a4c5dd727f41148 \
    DEBIAN_FRONTEND=noninteractive

RUN \
    apt update && apt install -y build-essential checkinstall zlib1g-dev curl && \
    cd /usr/local/src/ && \
    curl https://www.openssl.org/source/openssl-${VERSION}.tar.gz -o openssl-${VERSION}.tar.gz && \
    sha256sum openssl-${VERSION}.tar.gz | grep ${SHA256} && \
    tar -xf openssl-${VERSION}.tar.gz && \
    cd /usr/local/src/openssl-${VERSION} && \
    ./config --prefix=/usr/local/ssl --openssldir=/usr/local/ssl shared zlib && \
    make && \
    make install_sw && \
    cd /etc/ld.so.conf.d/ && \
    echo "/usr/local/ssl/lib" > openssl-${VERSION}.conf && \
    ldconfig -v

WORKDIR /

ENV \
    PATH=/usr/local/ssl/bin:$PATH \
    SSL_CERT_FILE=/etc/ssl/certs/ca-certificates.crt \
    SSL_CERT_DIR=/etc/ssl/certs

ADD Dispatch/ ./Dispatch/
RUN chmod -R +x ./Dispatch/
ADD entrypoint.ps1 /entrypoint.ps1
ADD entrypoint.sh /entrypoint.sh
RUN chmod +x /entrypoint.*

# Code file to execute when the docker container starts up
ENTRYPOINT ["/entrypoint.sh"]