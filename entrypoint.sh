#!/bin/sh -l

echo "Starting Discord deploy"

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

echo "Using config ($INPUT_CONFIGPATH) for $BRANCH_ID to build ($INPUT_BUILDPATH)"

/Dispatch/dispatch build push $BRANCH_ID $INPUT_CONFIGPATH $INPUT_BUILDPATH -p

echo "Discord deploy completed"