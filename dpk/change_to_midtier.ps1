$computername = $env:computername
$puppet_home="c:\psft\dpk\puppet"
$start_location=$(Get-Location)
$start_time = $(get-date)

function change_to_midtier() {
  Write-Host "[${computername}][Task] Change env_type to 'midtier'"
  (Get-Content "${puppet_home}\production\data\defaults.yaml").replace("env_type: fulltier", "env_type: midtier") | Set-Content "${puppet_home}\production\data\defaults.yaml"
  (Get-Content "${puppet_home}\production\manifests\site.pp") -replace 'include.*', "include ::pt_role::pt_app_midtier" | Set-Content "${puppet_home}\production\manifests\site.pp"
  Copy-Item -Path .\psft_customizations.yaml -Destination "${puppet_home}\production\data" 
  Write-Host "[${computername}][Done] Change env_type to 'midtier'" -ForegroundColor Green
}

function deploy_oracle_client() {
  Write-Host "[${computername}][Task] Run Puppet to Deploy Oracle Client"
  Stop-Service Psft* -WarningAction SilentlyContinue
  Set-Location $puppet_home\production\manifests
  puppet apply -e "include pt_profile::pt_tools_deployment" --confdir=$puppet_home  2>&1 | out-null
  $oracle_client_location = $(hiera oracle_client_location -c $puppet_home\hiera.yaml)
  if (Test-Path $oracle_client_location) {
    Write-Host "[${computername}][Done] Run Puppet to Deploy Oracle Client" -ForegroundColor Green
  } else {
    Write-Host "[${computername}][Error] Oracle Client did not deploy" -ForegroundColor Red
  }
  
}

function report_elapsed_time() {
  $elapsedTime = $(get-date) - $start_time
  $totalTime = "{0:HH:mm:ss}" -f ([datetime]$elapsedTime.Ticks)
  Write-Host "[${computername}][Time] ${totalTime}"
}

. change_to_midtier
. deploy_oracle_client
. report_elapsed_time

Set-Location $start_location