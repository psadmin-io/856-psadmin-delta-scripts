<#PSScriptInfo
    .SYNOPSIS
        Configure Change Assistant
    .DESCRIPTION
        Import General Options options into a fresh Change Assistant installation
    .PARAMETER ACTION
        Action to perform against Change Assistant. Valid actions are: 
          * options
          * pumsource
          * exportcfg
          * importcfg 
          * createdb
          * updatedb
          * uploaddb
    .PARAMETER PT_VERSION
        PeopleTools Version for Change Assistant
    .PARAMETER PI_VERSION
        Application and Release of the PeopleSoft Image
    .EXAMPLE
        configureCA.ps1 -action exportcfg -pt_version 8.56.03 -pi_version hr024
#>

# Parameter help description
[CmdletBinding()]
Param(
  [Parameter(Mandatory=$true)][String]$ACTION         = "other",
  [Parameter()][String]$BASE                          = "c:\psft",
  [Parameter(Mandatory=$true)][String]$PT_VERSION     = "NOTSET",
  [Parameter()][String]$PI_VERSION                    = "NOTSET",
  [Parameter()][String]$DATABASE                      = "HCMWIN",
  [Parameter()][String]$ORACLE_VERSION                = "12.1.0.2",
  [Parameter()][String]$ACCESS_ID                     = "SYSADM",
  [Parameter()][String]$ACCESS_PWD                    = "SYSADM",
  [Parameter()][String]$DB_CONNECT_ID                 = "people",
  [Parameter()][String]$DB_CONNECT_PWD                = "peop1e",
  [Parameter()][String]$DB_USER                       = "VP1",
  [Parameter()][String]$DB_PWD                        = "VP1",
  [Parameter()][String]$CLIENT_LOCATION               = "C:\PT${PT_VERSION}_Client_ORA",
  [Parameter()][String]$APP                           = "hcm",
  [Parameter()][String]$DNS_NAME                      = "psterraform.ec2.internal"
)

# Valid values: "Stop", "Inquire", "Continue", "Suspend", "SilentlyContinue"
$ErrorActionPreference = "Stop"
$DebugPreference = "SilentlyContinue"
$VerbosePreference = "SilentlyContinue"

function build_path_variables {  
    $SQLPLUS_LOCATION="${BASE}\db\oracle-server\${ORACLE_VERSION}\BIN\sqlplus.exe"
    if ($PI_VERSION -eq "NOTSET") {
        $CA_PATH = "C:\Program Files\PeopleSoft\Change Assistant"
    } else {
        $CA_PATH="${BASE}\ca\${PI_VERSION}-${PT_VERSION}"
    }
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
        -EMYN N `
}

function define_pum_source {
    
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
        -EMYN N `
        -SRCYN Y `
        -SRCENV "${DATABASE}" `
        -PUH "${BASE}\pt\${APP}_pi_home" `
        -PIA "http://${DNS_NAME}:8000/ps/signon.html"
}

function export_ca_config {
  Set-Location $CA_PATH
  & "${CA_PATH}\changeassistant.bat" `
      -MODE UM `
      -ACTION EXPCFG `
      -FILEPATH $BASE\ca `
      -FILE casettings.zip `
      -DBDEFN ALLDATABASE `
      -OVERWRITE Y
}

function import_ca_config {
  Set-Location $CA_PATH
  & "${CA_PATH}\changeassistant.bat" `
      -MODE UM `
      -ACTION IMPCFG `
      -FILEPATH $BASE\ca `
      -FILE casettings.zip `
      -DBDEFN ALLDATABASE `
      -REPLACEDB Y
}

function create_new_database {
  Set-Location $CA_PATH
  & "${CA_PATH}\changeassistant.bat" `
      -MODE UM `
      -ACTION ENVCREATE `
      -TGTENV ${DATABASE} `
      -CT 2 `
      -UNI Y `
      -CA ${ACCESS_ID} `
      -CAP ${ACCESS_PWD} `
      -CO ${DB_USER} `
      -CP ${DB_PWD} `
      -CI ${DB_CONNECT_ID} `
      -CW ${DB_CONNECT_PWD} `
      -CZYN N `
      -SQH ${SQLPLUS_LOCATION} `
      -INP All `
      -PL HCM `
      -IND ALL `
      -INL All `
      -INBL ENG `
      -PSH ${CLIENT_LOCATION} `
      -PAH ${CLIENT_LOCATION} `
      -PCH ${CLIENT_LOCATION} `
      -REPLACE N
}

# Stubbed for future feature
function update_database {
  Set-Location $CA_PATH
  & "${CA_PATH}\changeassistant.bat" `
      -MODE UM `
      -ACTION ENVUPDATE `
      -TGTENV=${DATABASE} `
      -CT=2 `
      -UNI=Y `
      -CA=${ACCESS_ID} `
      -CAP=${ACCESS_PWD} `
      -CO=${DB_USER} `
      -CP=${DB_USER_PWD} `
      -CI=${DB_CONNECT_ID} `
      -CW=${DB_CONNECT_PWD} `
      -CZYN=N `
      -SQH=${SQLPLUS_LOCATION} `
      -INP=All `
      -PL=HCM `
      -IND=ALL `
      -INL=All `
      -INBL=ENG `
      -PSH=${CLIENT_LOCATION} `
      -PAH=${CLIENT_LOCATION} `
      -PCH=${CLIENT_LOCATION} `
      -REPLACE=Y
}

function upload_database_to_pum {
    Set-Location $CA_PATH
    & "${CA_PATH}\changeassistant.bat" `
        -MODE UM `
        -ACTION UPLDTGT `
        -TGTENV $DATABASE `
        -EXONERR N
}

. build_path_variables
. create_ca_folders
switch ($ACTION) {
  "options" { 
    . load_general_settings
   }
   "pumsource" { 
    . define_pum_source
   }
   "exportcfg" {
    . export_ca_config
   }
   "importcfg" {
     . import_ca_config
   }
   "createdb" {
     . create_new_database
   }
   "updatedb" {
     . update_database
   }
   "uploaddb" {
     . upload_database_to_pum
   }
  Default {
    Write-Host "-action is invalid. Valid actions are: options, exportcfg, importcfg, createdb, updatedb, uploaddb"
  }
}

Set-Location $START_LOCATION