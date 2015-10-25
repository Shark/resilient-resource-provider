FROM ruby:2.2-onbuild
MAINTAINER Felix Seidel <felix@seidel.me>

RUN apt-get update && \
    apt-get install -y unzip && \
    wget -O /tmp/envconsul.zip https://github.com/hashicorp/envconsul/releases/download/v0.6.0/envconsul_0.6.0_linux_amd64.zip && \
    mkdir /app && \
    cd /app && \
    unzip /tmp/envconsul.zip && \
    rm /tmp/*.zip && \
    apt-get autoremove -y --purge unzip && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/* && \
    useradd -u 500 core

ENV RACK_ENV production
USER core
CMD ["/app/envconsul", "-consul", "172.17.42.1:8500", "-prefix", "calculator_provider/config", "bundle", "exec", "ruby", "calculator_provider.rb"]
