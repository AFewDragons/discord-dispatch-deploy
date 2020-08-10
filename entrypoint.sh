#!/bin/sh -l

echo "Starting Discord deploy"

ls

mkdir ~/.dispatch
cp $RUNNER_SPACE/Dispatch/credentials.json ~/.dispatch/credentials.json
sed -i "s/app_id_goes_here/$INPUT_APPID/" ~/.dispatch/credentials.json
sed -i "s/token_goes_here/$INPUT_BOTTOKEN/" ~/.dispatch/credentials.json
chmod +x $RUNNER_SPACE/Dispatch/dispatch

$RUNNER_SPACE/Dispatch/dispatch branch list $INPUT_APPID > branches.txt
if grep -q $INPUT_BRANCHID branches.txt; then
  echo "branch exists"
else
  echo "branch does not exists; creating"
  $RUNNER_SPACE/Dispatch/dispatch branch create $INPUT_APPID $INPUT_BRANCHID
fi

$RUNNER_SPACE/Dispatch/dispatch branch list $INPUT_APPID > branches.txt
BRANCH_ID=$(grep $INPUT_BRANCHID branches.txt | cut -d'|' -f3 - | tr -d '[:space:]')
$RUNNER_SPACE/Dispatch/dispatch build push $BRANCH_ID $GITHUB_WORKSPACE/$INPUT_CONFIGPATH $GITHUB_WORKSPACE/$INPUT_BUILDPATH -p

echo "Discord deploy completed"