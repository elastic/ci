#!/bin/bash
#
# generate es server starting command line values
# this is called when the job needs to start certain version of elasticsearch
#
ruby $WORKSPACE/master/ci/es_launch_properties.rb
if $CI_DEBUG ; then
   cat es_prop.txt
fi