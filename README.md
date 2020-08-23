# Discord - Dispatch Deploy

This action will deploy a single application to Discord using Discord Dispatch

## Inputs

### `applicationId`

**Required** The ID of your Discord application. (It is advisable to use this as a secret).

### `branchName`

**Required** The name of the branch that will be used to push the build to. This will create a new branch if one is not found under that name.

### `botToken`

**Required** The bot token found for your application from the Discord developer section of your application.

### `configPath`

**Required** The path to your Discord Dispatch config file. This should only contain one build and that build should have an application directory of './'

### `buildPath`

**Required** The path of the build to be pushed. Make sure the folder contains the executable that your config is pointing to.

### `drmWrap`

*Optional* Boolean to specify whether or not to apply Discord DRM protection.

### `executableName`

*Optional* The name of the executable. This is **required** if drmWrap is `true`.

## Outputs

No outputs

## Example usage

### Without DRM

```yaml
uses: AFewDragons/Discord-Dispatch-Deploy@v1-alpha.2
  with:
    applicationId: ${{ secrets.APP_ID }}
    branchName: dev
    botToken: ${{ secrets.TOKEN }}
    configPath: ./config.json
    buildPath: ./Build/
```

### With DRM

```yaml
uses: AFewDragons/Discord-Dispatch-Deploy@v1-alpha.2
  with:
    applicationId: ${{ secrets.APP_ID }}
    branchName: dev
    botToken: ${{ secrets.TOKEN }}
    configPath: ./config.json
    buildPath: ./Build/
    drmWrap: true
    executableName: "My Application.exe"
```