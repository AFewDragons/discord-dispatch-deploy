<#
    .SYNOPSIS
    Deploy an Application to Discord
    .DESCRIPTION
    Deploy an application to Discord using Discord Dispatch
#>

[CmdletBinding()]
param (
    [Parameter()]
    [string]$BranchName = $env:BranchName,

    [Parameter()]
    [string]$ConfigPath = $env:ConfigPath,
    
    [Parameter()]
    [string]$BuildPath = $env:BuildPath,

    [Parameter()]
    [string]$ApplicationId = $env:ApplicationId,
    
    [Parameter()]
    [string]$BotToken = $env:BotToken,

    [Parameter()]
    [bool]$DrmWrap = [bool]::parse($env:DrmWrap) ?? $false,

    [Parameter()]
    [string]$ExecutableName = $env:ExecutableName
)

#Requires -Version 7.0

# Set preference to Stop if errors are experienced
$ErrorActionPreference = 'Stop'

# Static variables
$CredentialsFilePath = "/Dispatch/credentials.json"
$DispatchProfilePath = "~/.dispatch"
$CredentialsFileTarget = "$DispatchProfilePath/credentials.json"

# Functions
function GetBranchId([string]$ApplicationId, [string]$BranchName)
{
    # Dispatch command to get list of branches for provided ApplicationId
    $Branches = $(& /Dispatch/dispatch branch list $ApplicationId)
    if ($LASTEXITCODE -ne 0) { Write-Error $Branches }
    # Obtain the BranchId for matching branches
    $BranchId = Select-String -InputObject $Branches -Pattern "\d+(?=\s*\|\s*$BranchName)" -AllMatches
    # Select the BranchId. If there are more than one matches, return exception
    !($BranchId.Matches.Count -gt 1) ? $($BranchId = ($BranchId.Matches | Select-Object -First 1).Value) : $(return Write-Error "There were $($BranchId.Matches.Count) branches with the name '$BranchName' detected!")
    # Return the BranchId variable
    return $BranchId
}

trap
{
    Write-Host "Error: $_"
    exit 1
}

try
{
    # Create Dispatch Profile directory
    New-Item -ItemType Directory -Path $DispatchProfilePath | Out-Null && Write-Host "Created directory $DispatchProfilePath"

    # Transform Credentials file and save to Dispatch Profile directory
    $CredentialsFile = Get-Content $CredentialsFilePath -Raw | ConvertFrom-Json
    $CredentialsFile.BotCredentials.application_id = $ApplicationId
    $CredentialsFile.BotCredentials.token = $BotToken
    $CredentialsFile | ConvertTo-Json | Set-Content $CredentialsFileTarget
    Write-Host "Imported credentials to $CredentialsFileTarget"

    # Get the BranchId using the GetBranchId function
    $BranchId = GetBranchId -ApplicationId $ApplicationId -BranchName $BranchName

    if (!$BranchId)
    {
        # No BranchId was returned, commence creating the branch
        Write-Host "Branch $BranchName does not exist; Creating.."

        # Dispatch command to create the branch
        $Command = $(& /Dispatch/dispatch branch create $ApplicationId $BranchName)
        if ($LASTEXITCODE -ne 0) { Write-Error $Command }

        # Get the newly created branch
        $BranchId = GetBranchId -ApplicationId $ApplicationId -BranchName $BranchName
        
        # Check that the branch was actually retrieved, else return exception
        if (!$BranchId) { Write-Error "Attempted to create branch $BranchName, but it still could not be found!" }

        Write-Host "Branch $BranchName [$BranchId] created."
    }

    if ($DrmWrap)
    {
        # Validate that an executable name was provided, else return exception
        if (!$ExecutableName) { Write-Error "DrmWrap was requested but no ExecutableName was provided!" }

        # Define the path to the executable
        $ExecutablePath = "$BuildPath/$ExecutableName"

        # Apply DRM to the executable
        $Command = $(& /Dispatch/dispatch build drm-wrap $ApplicationId $ExecutablePath)
        if ($LASTEXITCODE -ne 0) { Write-Error $Command }

        Write-Host "DRM has been applied to $ExecutablePath"
    }

    # Deploy the application to Discord with Dispatch
    Write-Host "Using config ($ConfigPath) for $BranchName [$BranchId] to build ($BuildPath).."
    $Command = $(& /Dispatch/dispatch build push $BranchId $ConfigPath $BuildPath)
    if ($LASTEXITCODE -ne 0) { Write-Error $Command }

    Write-Host "Discord deploy completed."
}
catch
{
    throw
}
