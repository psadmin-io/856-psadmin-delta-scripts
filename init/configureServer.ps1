  # Prepare Course Configuration
  choco install git.install -y
  New-Item c:/vagrant/dmw/security -ItemType Directory
  Set-Location c:/vagrant
  & 'C:\Program Files\Git\bin\git.exe' clone https://github.com/psadmin-io/856-psadmin-delta-scripts.git
  # New-SmbShare -Name dmw -Path c:/vagrant/dmw
  # Grant-SmbShareAccess -Name dmw -AccountName Everyone -AccessRight Full -force