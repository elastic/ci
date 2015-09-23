#!/bin/bash
# force cleanup
bash -x ci/$GIT_BRANCH/killDanglingJVMS.sh $HOME/.m2/repository/commons-codec/commons-codec/
exit 0