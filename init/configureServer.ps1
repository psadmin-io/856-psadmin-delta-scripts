function install_choco_packages {  
  choco install git.install -y
  choco install selenium-chrome-driver -y
  choco install selenium-gecko-driver -y
}

function download_scripts {
  New-Item c:/vagrant/dmw/security -ItemType Directory
  Set-Location c:/vagrant
  & 'C:\Program Files\Git\bin\git.exe' clone https://github.com/psadmin-io/856-psadmin-delta-scripts.git
}

function install_gems {
  $env:PATH+=";C:\Program Files\Puppet Labs\Puppet\sys\ruby\bin"
  [Environment]::SetEnvironmentVariable("PATH", $env:PATH, "Machine")

  Copy-Item -Path "C:\vagrant\856-psadmin-delta-scripts\init\rubyGemsCA.pem" -Destination "C:\Program Files\Puppet Labs\Puppet\sys\ruby\lib\ruby\2.1.0\rubygems\ssl_certs"
  # $puppetGemFolder = Resolve-Path 'C:\Program Files\Puppet Labs\Puppet\sys\ruby\lib\ruby\*\rubygems\ssl_certs\'
  $CACertFile = Join-Path -Path $ENV:AppData -ChildPath 'RubyCACert.pem'

  If (-Not (Test-Path -Path $CACertFile)) {  
    "Downloading CA Cert bundle.."
    [Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12
    Invoke-WebRequest -Uri 'https://curl.haxx.se/ca/cacert.pem' -UseBasicParsing -OutFile $CACertFile | Out-Null
  }
  
  "Setting CA Certificate store set to $CACertFile.."
  $ENV:SSL_CERT_FILE = $CACertFile
  [System.Environment]::SetEnvironmentVariable('SSL_CERT_FILE',$CACertFile, [System.EnvironmentVariableTarget]::Machine)

  "Installing Gems"
  #gem install psadmin_plus
  gem install selenium-webdriver
  gem install rspec
}
function configure_tns {
  if (!(Get-Content C:\psft\db\tnsnames.ora | Select-String HCMLNX)) { 
    Add-Content -Path "C:\psft\db\tnsnames.ora" -Value "`n `
HCMLNX = `
  (DESCRIPTION = `
      (ADDRESS_LIST = `
          (ADDRESS = (PROTOCOL = TCP)(HOST = 10.0.0.10)(PORT = 1522)) `
      ) `
      (CONNECT_DATA = `
          (SERVER = DEDICATED) `
          (SERVICE_NAME = HCMLNX) `
      ) `
    )"
  }
}
  
function load_cust_project {
  Set-Location C:\psft\pt\ps_home*\bin\client\winx86
  .\pside.exe -HIDE -CT ORACLE -CD HCMWIN -CO PS -CP PS -CI people -CW peop1e -PJFF IO_POS_DATA -FP C:\vagrant\856-psadmin-delta-scripts -LF c:\temp\copy.log
  .\pside.exe -HIDE -CT ORACLE -CD HCMWIN -CO PS -CP PS -CI people -CW peop1e -PJB IO_POS_DATA -LF c:\temp\build.log
}

function configure_profile {
  $profile_file = "C:\Users\Administrator\Documents\WindowsPowerShell\profile.ps1"
  if (!(test-path $profile_file)) {
    Add-Content -Path $profile_file -Value "`$env:PATH+=`";C:\Program Files\Puppet Labs\Puppet\sys\ruby\bin`""
    Add-Content -Path $profile_file -Value "`$env:PATH+=`";C:\Program Files\Mozilla Firefox`""
  }
}

function map_drives {
  net use t: \\10.0.0.10\tools_client
}

# Prepare Course Configuration
. install_choco_packages
. download_scripts
. install_gems
. configure_tns
. load_cust_project
. configure_profile
. map_drives