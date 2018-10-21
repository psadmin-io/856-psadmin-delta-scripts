param(
    [Parameter(Mandatory=$true)][SecureString]$password
)

$MOSPass = [Runtime.InteropServices.Marshal]::PtrToStringAuto([Runtime.InteropServices.Marshal]::SecureStringToBSTR($password))

[Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12
if (!(test-path c:\psft\getMOSPatch.zip)) {
    invoke-webrequest -uri https://github.com/MarisElsins/getMOSPatch/archive/V2.1.zip -outfile getMOSPatch.zip
    Expand-Archive getMOSPatch.zip -DestinationPath .\; copy-item .\getMOSPatch-2.1\getMOSPatch.jar c:\psft\
}

java -jar c:\psft\getMOSPatch.jar patch=28615231 platform=233P MOSUser=dan@psadmin.io MOSPass=$MOSPass download=all
expand-archive .\ELASTICSEARCH*.zip -DestinationPath .\es
set-location .\es\setup
.\psft-dpk-setup.bat --install --install_base_dir=c:\psft\elastic
 
