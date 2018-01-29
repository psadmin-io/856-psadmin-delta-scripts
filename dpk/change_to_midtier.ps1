$computername = $env:computername
$PUPPET_HOME="c:\psft\dpk\puppet"

function change_to_midtier() {
  Write-Host "[${computername}][Task] Change env_type to 'midtier'"
  (Get-Content "${PUPPET_HOME}\production\data\defaults.yaml").replace("env_type: fulltier", "env_type: midtier") | Set-Content "${PUPPET_HOME}\production\data\defaults.yaml"
  (Get-Content "${PUPPET_HOME}\production\manifests\site.pp") -replace 'include.*', "include ::pt_role::pt_app_midtier" | Set-Content "${PUPPET_HOME}\production\manifests\site.pp"
  Copy-Item -Path .\psft_customizations.yaml -Destination "${PUPPET_HOME}\production\data"
  Write-Host "[${computername}][Done] Change env_type to 'midtier'" -ForegroundColor Green
}

function deploy_oracle_client() {
  Write-Host "[${computername}][Task] Run Puppet to Deploy Oracle Client"
  Stop-Service Psft*
  Set-Location $PUPPET_HOME\production\manifests
  puppet apply .\site.pp --confdir=$PUPPET_HOME
  $oracle_client_location = $(hiera oracle_client_location -c $PUPPET_HOME\hiera.yaml)
  if (Test-Path $oracle_client_location) {
    Write-Host "[${computername}][Done] Run Puppet to Deploy Oracle Client" -ForegroundColor Green
  } else {
    Write-Host "[${computername}][Error] Oracle Client did not deploy" -ForegroundColor Red
  }
  
}

. change_to_midtier
. deploy_oracle_client