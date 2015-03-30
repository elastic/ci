#!/bin/bash
source /mnt/jenkins/nvm/bash_profile
nvm use $NODE_V
nvm ls
npm config set registry http://registry.npmjs.org/
npm install
# race condition
npm install -g grunt-cli
npm update
grunt setup
unset http_proxy
grunt -d package
