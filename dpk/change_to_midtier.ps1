$computername = $env:computername
$PUPPET_HOME="c:\psft\dpk\puppet"

function change_to_midtier() {
  Write-Host "[${computername}][Task] Change env_type to 'midtier'"
  (Get-Content "${PUPPET_HOME}\production\data\defaults.yaml").replace("env_type: fulltier", "env_type: midtier") | Set-Content "${PUPPET_HOME}\production\data\defaults.yaml"
  (Get-Content "${PUPPET_HOME}\production\manifests\site.pp") -replace 'include.*', "include ::pt_role::pt_app_midtier" | Set-Content "${PUPPET_HOME}\production\manifests\site.pp"
  Write-Host "[${computername}][Done] Change env_type to 'midtier'" -ForegroundColor Green
}

. change_to_midtier