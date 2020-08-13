#!/bin/sh -l

echo "Starting Discord deploy"

mkdir ~/.dispatch
cp /Dispatch/credentials.json ~/.dispatch/credentials.json
sed -i "s/app_id_goes_here/$INPUT_APPLICATIONID/" ~/.dispatch/credentials.json
sed -i "s/token_goes_here/$INPUT_BOTTOKEN/" ~/.dispatch/credentials.json
chmod +x /Dispatch/dispatch

/Dispatch/dispatch branch list $INPUT_APPLICATIONID > branches.txt
BRANCH_ID=$(grep -oP "$INPUT_BRANCHID\s*\|\s*\K\d*" branches.txt)

if [ $BRANCH_ID ]; then
  echo "Branch $INPUT_BRANCHID [$BRANCH_ID] exists"
else
  echo "Branch $INPUT_BRANCHID does not exist; creating.."
  /Dispatch/dispatch branch create $INPUT_APPLICATIONID $INPUT_BRANCHID
  /Dispatch/dispatch branch list $INPUT_APPLICATIONID > branches.txt
  BRANCH_ID=$(grep -oP "$INPUT_BRANCHID\s*\|\s*\K\d*" branches.txt)
  echo "Branch $INPUT_BRANCHID [$BRANCH_ID] created"
fi

echo "Using config ($INPUT_CONFIGPATH) for $INPUT_BRANCHID [$BRANCH_ID] to build ($INPUT_BUILDPATH)"

/Dispatch/dispatch build push $BRANCH_ID $INPUT_CONFIGPATH $INPUT_BUILDPATH -p

echo "Discord deploy completed"