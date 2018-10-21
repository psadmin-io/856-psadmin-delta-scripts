$clientcfg = @"
[PSTOOLS]
ConnectId=REG_SZ=people
ClientConnectPswd=REG_SZ=kyD3QPxnrahVqMoEo52IrWbJU0L9rFPDJ/2fneIL
"@
$cfgfile = New-Item -type file "c:\temp\pscfg.cfg" -force
$clientcfg | out-file $cfgfile -Encoding ascii

set-location c:\psft\pt\ps_home*\bin\client\winx86
.\pscfg -import:c:\temp\pscfg.cfg
