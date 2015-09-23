#!/bin/bash
#
# generate es server starting command line values
# this is called when the job needs to start certain version of elasticsearch
#
ruby $WORKSPACE/ci/$GIT_BRANCH/es_launch_properties.rb
if [ "$CI_DEBUG" = true ] ; then
   cat es_prop.txt
fi