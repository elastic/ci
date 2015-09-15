#!/bin/bash -x
# perform atomic update of the userContent
old_content=$JENKINS_HOME/userContent
new_content=${old_content}.new
cp -r -f $WORKSPACE $JENKINS_HOME/$BUILD_TAG
ln -s $JENKINS_HOME/$BUILD_TAG $new_content
if [ -e $old_content ]
then
    mv -f -t $new_content $old_content
else
    ln -s $JENKINS_HOME/$BUILD_TAG $old_content
    rm  $new_content
fi
# clean up old ones
directory_prefix=${BUILD_TAG%-*}
find $JENKINS_HOME -type d -maxdepth 1 ! -name $BUILD_TAG -name "${directory_prefix}*" -exec rm -r -f {} \;
