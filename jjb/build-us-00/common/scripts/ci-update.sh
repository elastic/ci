#!/bin/bash -x
# perform atomic update of the userContent
#
# the key point is use of mv -T which is supposed to do atomic symbolic link update
#
old_content=$JENKINS_HOME/userContent/ci/${GIT_BRANCH}
ci_directory=`dirname $old_content`
new_content=${old_content}.new

mkdir -p $ci_directory
cp -r -f $WORKSPACE $ci_directory/$BUILD_TAG
ln -s $ci_directory/$BUILD_TAG $new_content
if [ -e $old_content ]
then
    mv -f -T $new_content $old_content
else
    ln -s `readlink $new_content` $old_content
    rm  $new_content
fi

# clean up old ones
directory_prefix=${BUILD_TAG%-*}
find $ci_directory -type d -maxdepth 1 ! -name $BUILD_TAG -name "${directory_prefix}*" -exec rm -r -f {} \;
