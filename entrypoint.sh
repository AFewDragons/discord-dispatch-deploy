#!/bin/sh -l

echo "Starting Discord deploy"

mkdir ~/.dispatch
cp /Dispatch/credentials.json ~/.dispatch/credentials.json
sed -i "s/app_id_goes_here/$INPUT_APPLICATIONID/" ~/.dispatch/credentials.json
sed -i "s/token_goes_here/$INPUT_BOTTOKEN/" ~/.dispatch/credentials.json
chmod +x /Dispatch/dispatch

/Dispatch/dispatch branch list $INPUT_APPLICATIONID > branches.txt
cat branches.txt
BRANCH_ID=$(grep -oP "$INPUT_BRANCHID\s*\|\s*\K\d*" branches.txt)
cat $BRANCH_ID

if [ $BRANCH_ID ]; then
  echo "branch exists"
else
  echo "branch does not exist; creating"
  /Dispatch/dispatch branch create $INPUT_APPLICATIONID $INPUT_BRANCHID
  /Dispatch/dispatch branch list $INPUT_APPLICATIONID > branches.txt
  BRANCH_ID=$(grep -oP "$INPUT_BRANCHID\s*\|\s*\K\d*" branches.txt)
  cat $BRANCH_ID
fi

echo "Using config ($INPUT_CONFIGPATH) for $INPUT_BRANCHID [$BRANCH_ID] to build ($INPUT_BUILDPATH)"

/Dispatch/dispatch build push $BRANCH_ID $INPUT_CONFIGPATH $INPUT_BUILDPATH -p

echo "Discord deploy completed"