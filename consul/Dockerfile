FROM ubuntu:trusty
MAINTAINER Felix Seidel <felix@seidel.me>

RUN apt-get update && \
    apt-get install -y wget unzip && \
    wget -O /tmp/consul.zip https://dl.bintray.com/mitchellh/consul/0.5.2_linux_amd64.zip && \
    wget -O /tmp/consul-ui.zip https://dl.bintray.com/mitchellh/consul/0.5.2_web_ui.zip && \
    mkdir /app /data && \
    cd /app && \
    unzip /tmp/consul.zip && \
    unzip /tmp/consul-ui.zip && \
    mv dist web-ui && \
    rm -r /tmp/*.zip && \
    useradd -u 500 core && \
    chown core:core /data && \
    apt-get autoremove --purge -y wget unzip && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/*

USER core
VOLUME /data
ENTRYPOINT ["/app/consul"]
