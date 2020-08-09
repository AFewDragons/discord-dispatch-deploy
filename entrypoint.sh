#!/bin/sh -l

echo "Starting Discord Dispatch build push"

APP_ID = $1
BRANCH_NAME = $2
TOKEN = $3
CONFIG_PATH = $4
BUILD_PATH = $5

mkdir ~/.dispatch
cp $GITHUB_WORKSPACE/Dispatch/credentials.json ~/.dispatch/credentials.json
sed -i "s/app_id_goes_here/$APP_ID/" ~/.dispatch/credentials.json
sed -i "s/token_goes_here/$TOKEN/" ~/.dispatch/credentials.json
chmod +x $GITHUB_WORKSPACE/Dispatch/dispatch

$GITHUB_WORKSPACE/Dispatch/dispatch branch list $1 > branches.txt
if grep -q $2 branches.txt; then
  echo "branch exists"
else
  echo "branch does not exists; creating"
  $GITHUB_WORKSPACE/Dispatch/dispatch branch create $1 $2
fi

$GITHUB_WORKSPACE/Dispatch/dispatch branch list $1 > branches.txt
BRANCH_ID=$(grep $2 branches.txt | cut -d'|' -f3 - | tr -d '[:space:]')
$GITHUB_WORKSPACE/Dispatch/dispatch build push $BRANCH_ID $GITHUB_WORKSPACE/$CONFIG_PATH $GITHUB_WORKSPACE/$BUILD_PATH -p

echo "Dispatch for application $1 completed"