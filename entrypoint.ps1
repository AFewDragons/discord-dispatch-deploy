<#
    .SYNOPSIS
    Deploy Application to Discord
    .DESCRIPTION
    Using Discord Dispatch, deploy an application to Discord
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
    [string]$BotToken = $env:BotToken
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
    # Create Dispatch Profile directory and copy in the credentials file
    New-Item -ItemType Directory -Path $DispatchProfilePath | Out-Null && Write-Host "Created directory $DispatchProfilePath"
    Copy-Item -Path $CredentialsFilePath -Destination $CredentialsFileTarget && Write-Host "Copied $CredentialsFilePath to $CredentialsFileTarget"

    # Transform Credentials file
    $CredentialsFile = Get-Content $CredentialsFileTarget
    $CredentialsFile = $CredentialsFile -replace "app_id_goes_here", $ApplicationId
    $CredentialsFile = $CredentialsFile -replace "token_goes_here", $BotToken
    $CredentialsFile | Set-Content $CredentialsFileTarget
    Write-Host "Imported credentials to $CredentialsFileTarget"

    # Get the BranchId using the GetBranchId function
    $BranchId = GetBranchId -ApplicationId $ApplicationId -BranchName $BranchName

    if ($BranchId)
    {
        # The BranchId was successfully retrieved
        Write-Host "Branch $BranchName [$BranchId] exists."
    }
    else
    {
        # No BranchId was returned, commence creating the branch
        Write-Host "Branch $BranchName does not exist; Creating.."

        # Dispatch command to create the branch
        $(& /Dispatch/dispatch branch create $ApplicationId $BranchName)

        # Get the newly created branch
        $BranchId = GetBranchId -ApplicationId $ApplicationId -BranchName $BranchName
        
        # Check that the branch was actually retrieved, else return exception
        if(!$BranchId) {Write-Error "Attempted to create branch $BranchName, but it still could not be found!"}

        Write-Host "Branch $BranchName [$BranchId] created."
    }

    # Deploy the application to Discord with Dispatch
    Write-Host "Using config ($ConfigPath) for $BranchName [$BranchId] to build ($BuildPath).."
    $(& /Dispatch/dispatch build push $BranchId $ConfigPath $BuildPath)

    Write-Host "Discord deploy completed."
}
catch
{
    throw
}