# Discord Dispatch-deploy

This action will deploy a single application too Discord using Dispatch

## Inputs

### `applicationId`

**Required** The ID of your Discord application. (It is advisable to use this as a secret).

### `branchName`

**Required** The name of the branch that will be used to push the build too. This will create a new branch if one is not found under that name.

### `botToken`

**Required** The bot token found in your application in the Discord developer section of your application.

### `configPath`

**Required** The path to your Discord Dispatch config file. This should only contain one build and that build should has a application directory of './'

### `buildPath`

**Required** The path of the build to be pushed. Make sure the folder contains the executable that your config is pointing too.

## Outputs

No outputs

## Example usage

uses: AFewDragons/Discord-Dispatch-Deploy@v1-alpha  
  with:  
    applicationId: ${{ secrets.APP_ID }}  
    branchName: dev  
    botToken: ${{ secrets.TOKEN }}  
    configPath: ./config.json  
    buildPath: ./Build/