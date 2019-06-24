#!/bin/bash


if ! ChangeId=$(git show HEAD --summary | grep "Change-Id:" | awk '{print $2}') \
	|| [ -z "$ChangeId" ]; then
	echo "HEAD doesn't have a Change-Id"
	exit
fi

if ! LatestRef=$(ssh -p 29418 goeltz@brainscales-r.kip.uni-heidelberg.de  \
	gerrit query --patch-sets "$ChangeId" \
	| grep ref | awk '{print $2}' | tail -n1 ) \
   || [ -z "$LatestRef" ]; then
	echo "Empty LatestRef for Change-Id $ChangeId"
	exit
fi


echo "Getting latest ref $LatestRef of Change-Id $ChangeId"
git fetch origin "$LatestRef" && git checkout FETCH_HEAD
