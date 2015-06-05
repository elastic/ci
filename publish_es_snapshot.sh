#!/usr/bin/env zsh

## Call something like:
##
##   cd ~/src/elastic/elasticsearch
##   GPG_PROFILE=es.drewr zsh -xv ../ci/publish_es_snapshot.sh

if [[ -z $GPG_PROFILE ]]; then
  echo set \$GPG_PROFILE; exit 1
fi

datesha=$(git ver) # need the git alias
br=$(git rev-parse --abbrev-ref HEAD) # branch name: 1.6, 1.x, etc.
ver=${br}-${datesha}
artifact=elasticsearch-${ver}.tar.gz

mvn versions:set -DnewVersion=${ver}
mvn clean package -DskipTests=true
s3c $GPG_PROFILE put -P target/releases/${artifact} \
       s3://packages.elasticsearch.org/infra/${artifact}
