<#PSScriptInfo
    .SYNOPSIS
        Configure Change Assistant
    .DESCRIPTION
        Import General Options options into a fresh Change Assistant installation
    .PARAMETER BASE
        DPK Base Folder (Optional - Defaults to c:\psft)
    .PARAMETER PT_VERSION
        PeopleTools Version for Change Assistant
    .PARAMETER PI_VERSION
        Application and Release of the PeopleSoft Image
    .PARAMETER ORACLE_VERSION
        Oracle Database version (Optional - Defaults to 12.1.0.2)
    .EXAMPLE
        configureCA.ps1 -base c:\psft -pt_version 8.56.03 -pi_version hr024
#>

# Parameter help description
[CmdletBinding()]
Param(
  [String]$BASE                                       = "c:\psft",
  [Parameter(Mandatory=$true)][String]$PT_VERSION     = "NOTSET",
  [Parameter(Mandatory=$true)][String]$PI_VERSION     = "NOTSET",
  [String]$ORACLE_VERSION                             = "12.1.0.2"
)

# Valid values: "Stop", "Inquire", "Continue", "Suspend", "SilentlyContinue"
$ErrorActionPreference = "Stop"
$DebugPreference = "SilentlyContinue"
$VerbosePreference = "SilentlyContinue"

function build_path_variables {  
    $CLIENT_LOCATION="C:\PT${PT_VERSION}_Client_ORA"
    $SQLPLUS_LOCATION="${BASE}\db\oracle-server\${ORACLE_VERSION}\BIN\sqlplus.exe"
    $CA_PATH="${BASE}\ca\${PI_VERSION}-${PT_VERSION}"
    $START_LOCATION = $(Get-Location)
}

function create_ca_folders {
    if (!(Test-Path $BASE\ca)) {
        mkdir $BASE\ca
        mkdir $BASE\ca\stage
        mkdir $BASE\ca\output
        mkdir $BASE\ca\download
      }
}

function load_general_settings {
    
    Set-Location $CA_PATH
    & "${CA_PATH}\changeassistant.bat" `
        -MODE UM `
        -ACTION OPTIONS `
        -OUT "${BASE}\ca\output\ca.log" `
        -REPLACE Y `
        -EXONERR Y `
        -SWP False `
        -MCP 5 `
        -PSH "${CLIENT_LOCATION}" `
        -STG "${BASE}\ca\stage" `
        -OD "${BASE}\ca\output" `
        -DL "${BASE}\ca\download" `
        -SQH "${SQLPLUS_LOCATION}" `
        -EMYN N 
}

. build_path_variables
. create_ca_folders
. load_general_settings

Set-Location $START_LOCATION