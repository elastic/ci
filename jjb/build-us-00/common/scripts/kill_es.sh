#!/bin/bash
# force cleanup
bash -x master/ci/killDanglingJVMS.sh $HOME/.m2/repository/commons-codec/commons-codec/
exit 0