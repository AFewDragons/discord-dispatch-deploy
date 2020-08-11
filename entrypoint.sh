#!/bin/sh -l

echo "Starting Discord deploy"

mkdir ~/.dispatch
cp /Dispatch/credentials.json ~/.dispatch/credentials.json
sed -i "s/app_id_goes_here/$INPUT_APPLICATIONID/" ~/.dispatch/credentials.json
sed -i "s/token_goes_here/$INPUT_BOTTOKEN/" ~/.dispatch/credentials.json
chmod +x /Dispatch/dispatch

/Dispatch/dispatch branch list $INPUT_APPLICATIONID > branches.txt
cat branches.txt

if grep $INPUT_BRANCHID branches.txt; then
  echo "branch exists"
else
  echo "branch does not exists; creating"
  /Dispatch/dispatch branch create $INPUT_APPLICATIONID $INPUT_BRANCHID
  /Dispatch/dispatch branch list $INPUT_APPLICATIONID > branches.tx
fi

BRANCH_ID=$(grep $INPUT_BRANCHID branches.txt | cut -d'|' -f3 - | tr -d '[:space:]')
/Dispatch/dispatch build push $BRANCH_ID $GITHUB_WORKSPACE/$INPUT_CONFIGPATH $GITHUB_WORKSPACE/$INPUT_BUILDPATH -p

ls

echo "Discord deploy completed"