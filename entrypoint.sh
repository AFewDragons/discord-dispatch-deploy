#!/bin/sh -l

echo "Starting Discord deploy"

RUST_BACKTRACE=1

mkdir ~/.dispatch
cp /Dispatch/credentials.json ~/.dispatch/credentials.json
sed -i "s/app_id_goes_here/$INPUT_APPLICATIONID/" ~/.dispatch/credentials.json
sed -i "s/token_goes_here/$INPUT_BOTTOKEN/" ~/.dispatch/credentials.json
chmod +x /Dispatch/dispatch

/Dispatch/dispatch branch list $INPUT_APPLICATIONID > branches.txt
cat branches.txt

if [grep -q $INPUT_BRANCHID branches.txt]; then
  echo "branch exists"
else
  echo "branch does not exists; creating"
  /Dispatch/dispatch branch create $INPUT_APPLICATIONID $INPUT_BRANCHID
  /Dispatch/dispatch branch list $INPUT_APPLICATIONID > branches.txt
fi

BRANCH_ID=$(grep $INPUT_BRANCHID branches.txt | cut -d'|' -f3 - | tr -d '[:space:]')
CONFIGPATH=$GITHUB_WORKSPACE/$INPUT_CONFIGPATH
APPLICATIONROOT=$GITHUB_WORKSPACE/$INPUT_BUILDPATH
/Dispatch/dispatch build push $BRANCH_ID $CONFIGPATH $APPLICATIONROOT -p

ls

echo "Discord deploy completed"