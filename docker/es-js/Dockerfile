# Dockerfile for elasticsearch.js testing
# https://github.com/elasticsearch/elasticsearch-js
FROM ubuntu:14.04
MAINTAINER Bill Hwang <bill.hwang@elasticsearch.com>
RUN rm /bin/sh && ln -s /bin/bash /bin/sh
RUN apt-get update && apt-get install -y build-essential libssl-dev curl git
RUN mkdir -p /usr/local/nvm
RUN curl https://raw.githubusercontent.com/creationix/nvm/v0.22.2/install.sh | NVM_DIR=/usr/local/nvm bash
RUN source /usr/local/nvm/nvm.sh && nvm install 0.10.35 && nvm install 0.11.14
RUN cd ~;git clone https://github.com/elasticsearch/elasticsearch-js.git
