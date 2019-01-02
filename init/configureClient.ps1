[CmdletBinding()]
Param(
    [Parameter(Mandatory=$true)][String]$PT_VERSION     = "NOTSET"
)
$clientcfg = @"
[PSTOOLS]
Start=REG_SZ=APPLICATION_DESIGNER
Language=REG_SZ=ENG
WindowWidth=REG_DWORD=640
WindowHeight=REG_DWORD=448
PanelSize=REG_SZ=CLIP
StartNavigator=REG_SZ=
PanelInNavigator=REG_SZ=
HighlightPopupMenuFlds=REG_SZ=NO
ShowDBName=REG_DWORD=0
MaxWorkInstances=REG_DWORD=250
TenKeyMode=REG_SZ=NO
DbFlags=REG_DWORD=0
Business Interlink Driver Directory=REG_SZ=
JDeveloper Directory=REG_SZ=
JDeveloper Launch Mapper CPath=REG_SZ=
FontFace=REG_SZ=MS Sans Serif
FontPoints=REG_DWORD=8
[Startup]
DBType=REG_SZ=ORACLE
ServerName=REG_SZ=
DBName=REG_SZ=PSFTDB
DBChange=REG_SZ=YES
UserId=REG_SZ=VP1
ConnectId=REG_SZ=people
ClientConnectPswdV1=REG_SZ={V1}PGxodCR5dGfa4EBz2mXk
AppName=REG_SZ=
AuthSrvName=REG_SZ=
[Cache Settings]
CacheBaseDir=REG_SZ=C:\PS\CACHE
[Trace]
TraceSql=REG_DWORD=0
TracePC=REG_DWORD=0
TraceAE=REG_DWORD=0
AETFileSize=REG_DWORD=500
TraceFile=REG_SZ=
[PSIDE\PCDebugger]
PSDBGSRV Listener Port=REG_DWORD=9500

[Crystal]
Trace=REG_SZ=NO
CrystalDir=REG_SZ=
TraceFile=REG_SZ=
CustomReports=REG_SZ=

[RemoteCall]
RCCBL Timeout=REG_DWORD=50
RCCBL Redirect=REG_DWORD=0
RCCBL Animate=REG_DWORD=0
Show Window=REG_DWORD=7

[Setup]
GroupName=REG_SZ=PeopleSoft 8
Icons=REG_DWORD=3
MfCobolDir=REG_SZ=

[PSIDE]
ReportOutputDir=REG_SZ=c:\psreports

[Profiles\Default\Database Options]

[Profiles\Default\Process Scheduler]
PS_HOME=REG_SZ=C:\PT${PT_VERSION}_Client_ORA\
CBLBIN=REG_SZ=C:\PT${PT_VERSION}_Client_ORA\cblbin
TEMP=REG_SZ=c:\temp
OutputDirectory=REG_SZ=c:\temp\
Log Directory=REG_SZ=c:\temp
CRWRPTPATH=REG_SZ=C:\PT${PT_VERSION}_Client_ORA\crw
DBBIN=REG_SZ=C:\PT${PT_VERSION}_Client_ORA\sqlbase
SQRBIN=REG_SZ=
WINWORD=REG_SZ=
PSSQRFLAGS=REG_SZ=
PSSQR=REG_SZ=C:\PT${PT_VERSION}_Client_ORA\sqr
Redirect Output=REG_DWORD=0
PS_APP_HOME=REG_SZ=
PS_CUST_HOME=REG_SZ=

[Profiles\Default\nVision]
SpacerWidth=REG_SZ=
MacroDir=REG_SZ=C:\PT${PT_VERSION}_Client_ORA\PS\EXCEL
StyleDir=REG_SZ=C:\PT${PT_VERSION}_Client_ORA\EXCEL\STYLESHEETS
TemplateDir=REG_SZ=C:\PT${PT_VERSION}_Client_ORA\PS\EXCEL
LayoutDir=REG_SZ=C:\USER\NVISION\LAYOUT
DrillDownDir=REG_SZ=C:\USER\NVISION\LAYOUT\DRILLDN
InstanceDir=REG_SZ=C:\USER\NVISION\INSTANCE
TraceLevel=REG_DWORD=0
AsofDateForLabels=REG_DWORD=0
RetrieveActiveTreeLabels=REG_DWORD=0

[Profiles\Default\IMAGE]

[Profiles\Default\Data Mover]
InputDir=REG_SZ=C:\PT${PT_VERSION}_Client_ORA\data
OutputDir=REG_SZ=C:\PT${PT_VERSION}_Client_ORA\data
LogDir=REG_SZ=c:\temp

[Profiles\Default\Application Engine]
Disable Restart=REG_DWORD=0
Debug=REG_DWORD=0
"@
$cfgfile = New-Item -type file "c:\temp\pscfg.cfg" -force
$clientcfg | out-file $cfgfile -Encoding ascii

set-location c:\PT${PT_VERSION}_Client_ORA\bin\client\winx86
.\pscfg -import:c:\temp\pscfg.cfg
