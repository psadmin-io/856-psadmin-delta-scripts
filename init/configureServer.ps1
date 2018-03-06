function install_packages {  
  choco install git.install -y
}

function download_scripts {
  New-Item c:/vagrant/dmw/security -ItemType Directory
  Set-Location c:/vagrant
  & 'C:\Program Files\Git\bin\git.exe' clone https://github.com/psadmin-io/856-psadmin-delta-scripts.git
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
  
# Prepare Course Configuration
. install_packages
. download_scripts
. configure_tns