#!/bin/bash

upstreamBranch="master"
testBranch="1.x"

if [ "$#" -eq 0 ]; then
    echo "usage: checkMissingCommits.sh TEST_BRANCH [UPSTREAM_BRANCH] [simple|advanced|verbose]"
    exit
fi

if [ "$#" -eq 1 ];  then
    testBranch=$1
    strategy="advanced"
fi

if [ "$#" -eq 2 ]; then
    testBranch=$1
    upstreamBranch=$2
    strategy="advanced"
fi

if [ "$#" -eq 3 ]; then
    testBranch=$1
    upstreamBranch=$2
    strategy=$3
fi

if [ "$#" -gt 3 ]; then
    echo "usage: checkMissingCommits.sh TEST_BRANCH [UPSTREAM_BRANCH] [simple|advanced|verbose]"
    exit
fi



if [[ "$strategy" == "simple" ]]; then

	git cherry -v $upstreamBranch $testBranch | grep +
	
elif [[ "$strategy" == "advanced" ]] || [[ "$strategy" -eq "verbose" ]]; then

	missingCommits=$(git cherry $upstreamBranch $testBranch | grep + | cut -d\  -f2)

	initialCommit=$(diff -u <(git rev-list --first-parent "$testBranch")  <(git rev-list --first-parent "$upstreamBranch") | sed -ne 's/^ //p' | head -1)

	upstreamLog=$(git log $initialCommit $upstreamBranch)

	while read -r line; do
		gitShowLine=$(git show -s --date=short  --format="%Cred%h%Creset,%Cblue%ad%Creset,%Cgreen%an%Creset,%s" $line)
		subject=$(cut -d, -f4 <<< "$gitShowLine")
		if grep -q -F "$subject" <<< "$upstreamLog"; then
		  	if [[ "$strategy" == "verbose" ]]; then
				echo -e $gitShowLine "\033[31mFOUND\033[0m"
			fi
		else
			if [[ "$strategy" == "verbose" ]]; then
				echo -e $gitShowLine "\033[31mNOT FOUND\033[0m"
			else
				echo -e $gitShowLine
		 	fi
		fi
	done <<< "$missingCommits"

else
	echo "usage: checkMissingCommits.sh TEST_BRANCH [UPSTREAM_BRANCH] [simple|advanced|verbose]"
    exit
fi