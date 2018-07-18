[CmdletBinding()]
Param(
    [String]$PS_HOME  = $env:PS_HOME,
    [String]$USER     = 'PS',
    [String]$PASS     = 'PS',
    [String]$DATABASE = 'HCMWIN',
    [String]$SERVER   = $(hostname)
)

$start_location = Get-Location
Set-Location $PS_HOME\utility
$env:PS_FILEDIR="${env:PS_CFG_HOME}\files"

try {
    ./psrunACM.bat $SERVER ORACLE $DATABASE $USER $PASS "${DATABASE}_REFRESH" EXEC
    ./psrunACM.bat $SERVER ORACLE $DATABASE $USER $PASS "${DATABASE}_CONFIG" EXEC
}
catch {
    Write-Host "Error running ACM for ${DATABASE} Refresh" -Foreground Red
    Write-Host "Exit Code: $lastexitcode" -Foreground Yellow
}
Set-Location $start_location