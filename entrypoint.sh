#!/bin/sh -l

echo "Starting Dispatch deploy build push"

echo "$GITHUB_ACTION_PATH"
echo "$GITHUB_EVENT_PATH"
echo "$GITHUB_ACTION"

ls

mkdir ~/.dispatch
cp $GITHUB_ACTION_PATH/Dispatch/credentials.json ~/.dispatch/credentials.json
sed -i "s/app_id_goes_here/$INPUT_APPID/" ~/.dispatch/credentials.json
sed -i "s/token_goes_here/$INPUT_BOTTOKEN/" ~/.dispatch/credentials.json
chmod +x $GITHUB_ACTION_PATH/Dispatch/dispatch

$GITHUB_ACTION_PATH/Dispatch/dispatch branch list $INPUT_APPID > branches.txt
if grep -q $INPUT_BRANCHID branches.txt; then
  echo "branch exists"
else
  echo "branch does not exists; creating"
  $GITHUB_ACTION_PATH/Dispatch/dispatch branch create $INPUT_APPID $INPUT_BRANCHID
fi

$GITHUB_ACTION_PATH/Dispatch/dispatch branch list $INPUT_APPID > branches.txt
BRANCH_ID=$(grep $INPUT_BRANCHID branches.txt | cut -d'|' -f3 - | tr -d '[:space:]')
$GITHUB_ACTION_PATH/Dispatch/dispatch build push $BRANCH_ID $GITHUB_WORKSPACE/$INPUT_CONFIGPATH $GITHUB_WORKSPACE/$INPUT_BUILDPATH -p

echo "Dispatch deploy for application $INPUT_APPID completed"