#!/bin/zsh

# set -euo pipefail

gerrit_remote=$(git config --local remote.review.url)
elements=("${(@s.:.)gerrit_remote}")
gerrit_url=${${elements[-2]}:gs./.}
gerrit_port=${${(@s:/:)${elements[-1]}}[-2]}

if ! ChangeId=$(git show HEAD --summary | grep "Change-Id:" | awk '{print $2}') \
	|| [ -z "$ChangeId" ]; then
	echo "HEAD doesn't have a Change-Id"
	exit
fi

if ! LatestRef=$(ssh -p ${gerrit_port} ${gerrit_url}  \
	gerrit query --patch-sets "$ChangeId" \
	| grep ref | awk '{print $2}' | tail -n1 ) \
   || [ -z "$LatestRef" ]; then
	echo "Empty LatestRef for Change-Id $ChangeId"
	exit
fi


echo "Getting latest ref $LatestRef of Change-Id $ChangeId"
git fetch origin "$LatestRef" && git checkout FETCH_HEAD

# from https://github.com/obreitwi/dot_zsh/blob/ff1239abc158bbad67909a53286404daf884a0e0/functions#L280
# gerrit_fetch_changesets() { 
#     remote="review"
#     localbranchname=gerrit_tree_view
# 
#     gerrit_remote=$(git config --local remote.review.url)
#     elements=("${(@s:/:)gerrit_remote}")
#     gerrit_project=${elements[-1]}
#     elements[-1]=()
#     gerrit_url=${(j./.)elements}
# 
#     elements=("${(@s.:.)gerrit_url}")
#     gerrit_port=${elements[-1]}
#     gerrit_url=${${elements[-2]}:gs./.}
# 
#     git branch -D $(git branch | grep "$localbranchname") &> /dev/null
#     ssh -p ${gerrit_port} ${gerrit_url} gerrit query "project:${gerrit_project} status:open" --current-patch-set | sed -n 's/\s*ref: //p' | while read REF
# do
#     git fetch "${remote}" "${REF}"
#     git branch $(echo "${REF}" | sed "s#refs/changes/../#${localbranchname}/#") FETCH_HEAD
# done
# }
