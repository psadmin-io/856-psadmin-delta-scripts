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
          * uploadproject
    .EXAMPLE
        configureCA.ps1 -action exportcfg
#>

# Parameter help description
[CmdletBinding()]
Param(
  [Parameter(Mandatory=$true)][String]$ACTION         = "other",
  [Parameter()][String]$BASE                          = "c:\psft",
  [Parameter()][String]$PT_VERSION                    = "",
  [Parameter()][String]$DATABASE                      = "PSFTDB",
  [Parameter()][String]$ORACLE_VERSION                = "12.1.0.2",
  [Parameter()][String]$ACCESS_ID                     = "SYSADM",
  [Parameter()][String]$ACCESS_PWD                    = "SYSADM",
  [Parameter()][String]$DB_CONNECT_ID                 = "people",
  [Parameter()][String]$DB_CONNECT_PWD                = "peop1e",
  [Parameter()][String]$DB_USER                       = "VP1",
  [Parameter()][String]$DB_PWD                        = "VP1",
  [Parameter()][String]$APP                           = "",
  [Parameter()][String]$DNS_NAME                      = "",
  [Parameter()][String]$PROJECT                       = ""
)

# Valid values: "Stop", "Inquire", "Continue", "Suspend", "SilentlyContinue"
$ErrorActionPreference = "Stop"
$DebugPreference = "SilentlyContinue"
$VerbosePreference = "SilentlyContinue"

function build_path_variables {  
    $SQLPLUS_LOCATION="${BASE}\db\oracle-server\${ORACLE_VERSION}\BIN\sqlplus.exe"
    $CA_PATH = "C:\Program Files\PeopleSoft\Change Assistant"
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
    param (
        [Parameter(Mandatory=$true)][String]$PT_VERSION,
        [Parameter(Mandatory=$true)][String]$SQLPLUS_LOCATION,
        [Parameter()][String]$CLIENT_LOCATION  = "C:\PT${PT_VERSION}_Client_ORA"
    )
    
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
    param (
        [Parameter(Mandatory=$true)][String]$DNS_NAME,
        [Parameter(Mandatory=$true)][String]$PT_VERSION,
        [Parameter()][String]$CLIENT_LOCATION  = "C:\PT${PT_VERSION}_Client_ORA"
    )
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
    param(
        [Parameter(Mandatory=$true)][String]$DATABASE,
        [Parameter(Mandatory=$true)][String]$ACCESS_ID,
        [Parameter(Mandatory=$true)][String]$ACCESS_PWD,
        [Parameter(Mandatory=$true)][String]$DB_USER,
        [Parameter(Mandatory=$true)][String]$DB_USER_PWD,
        [Parameter(Mandatory=$true)][String]$DB_CONNECT_ID,
        [Parameter(Mandatory=$true)][String]$DB_CONNECT_PWD,
        [Parameter(Mandatory=$true)][String]$PT_VERSION,
        [Parameter()][String]$SQLPLUS_LOCATION,
        [Parameter()][String]$CLIENT_LOCATION  = "C:\PT${PT_VERSION}_Client_ORA"
    )
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

function update_database {
    param(
        [Parameter(Mandatory=$true)][String]$DATABASE,
        [Parameter(Mandatory=$true)][String]$ACCESS_ID,
        [Parameter(Mandatory=$true)][String]$ACCESS_PWD,
        [Parameter(Mandatory=$true)][String]$DB_USER,
        [Parameter(Mandatory=$true)][String]$DB_USER_PWD,
        [Parameter(Mandatory=$true)][String]$DB_CONNECT_ID,
        [Parameter(Mandatory=$true)][String]$DB_CONNECT_PWD,
        [Parameter(Mandatory=$true)][String]$PT_VERSION,
        [Parameter()][String]$SQLPLUS_LOCATION,
        [Parameter()][String]$CLIENT_LOCATION  = "C:\PT${PT_VERSION}_Client_ORA"
    )
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
    param(
        [Parameter(Mandatory=$true)][String]$DATABASE
    )
    Set-Location $CA_PATH
    & "${CA_PATH}\changeassistant.bat" `
        -MODE UM `
        -ACTION UPLDTGT `
        -TGTENV $DATABASE `
        -EXONERR N
}

function upload_project_to_pum {
    param(
        [Parameter(Mandatory=$true)]$DATABASE,
        [Parameter(Mandatory=$true)]$PROJECT
    )

    Write-Host "Uploading ${PROJECT} from ${DATABASE} to the Update Manager" -ForegroundColor Green

    Set-Location $CA_PATH
    & "${CA_PATH}\changeassistant.bat" `
        -MODE UM `
        -ACTION UPLDCUSTDATA `
        -RPSTTYPE CUST `
        -PRJTYPE MO `
        -PRJFROMDB ${DATABSE}:${PROJECT} `
        -REPLACE Y `
        -EXONERR Y
}

. build_path_variables
. create_ca_folders
switch ($ACTION) {
  "options" { 
    . load_general_settings $PT_VERSION $SQLPLUS_LOCATION
   }
   "pumsource" { 
    . define_pum_source $DNS_NAME $PT_VERSION
   }
   "exportcfg" {
    . export_ca_config
   }
   "importcfg" {
     . import_ca_config
   }
   "createdb" {
     . create_new_database $DATABASE $ACCESS_ID $ACCESS_PWD $DB_USER $DB_USER_PWD $DB_CONNECT_ID $DB_CONNECT_PWD $PT_VERSION $SQLPLUS_LOCATION
   }
   "updatedb" {
     . update_database $DATABASE $ACCESS_ID $ACCESS_PWD $DB_USER $DB_USER_PWD $DB_CONNECT_ID $DB_CONNECT_PWD $PT_VERSION $SQLPLUS_LOCATION
   }
   "uploaddb" {
     . upload_database_to_pum $DATABASE
   }
   "uploadproject" {
     . upload_project_to_pum $DATABASE $PROJECT
   }
  Default {
    Write-Host "-action is invalid. Valid actions are: options, exportcfg, importcfg, createdb, updatedb, uploaddb"
  }
}

Set-Location $START_LOCATION