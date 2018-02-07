class io_role::io_app_midtier inherits pt_role::pt_base {
  notify { "Applying io_role::io_app_midtier": }

  $ensure   = hiera('ensure')
  $env_type = hiera('env_type')

  if !($env_type in [ 'fulltier', 'midtier']) {
    fail('The pt_app_midtier role can only be applied to env_type of midtier or fulltier')
  }
  contain ::pt_profile::pt_app_deployment
  contain ::pt_profile::pt_tools_deployment
  contain ::pt_profile::pt_psft_environment
  contain ::pt_profile::pt_appserver
  contain ::pt_profile::pt_prcs
  contain ::pt_profile::pt_pia
  contain ::io_profile::io_pia
  contain ::pt_profile::pt_samba
  contain ::pt_profile::pt_source_details
  contain ::pt_profile::pt_password

  if $ensure == present {
    contain ::pt_profile::pt_tools_preboot_config
    contain ::pt_profile::pt_domain_boot
    contain ::pt_profile::pt_tools_postboot_config

    Class['::pt_profile::pt_system'] ->
    Class['::pt_profile::pt_app_deployment'] ->
    Class['::pt_profile::pt_tools_deployment'] ->
    Class['::pt_profile::pt_psft_environment'] ->
    Class['::pt_profile::pt_appserver'] ->
    Class['::pt_profile::pt_prcs'] ->
    Class['::pt_profile::pt_pia'] ->
    Class['::io_profile::io_pia'] ->
    Class['::pt_profile::pt_samba'] ->
    Class['::pt_profile::pt_password'] ->
    Class['::pt_profile::pt_tools_preboot_config'] ->
    Class['::pt_profile::pt_domain_boot'] ->
    Class['::pt_profile::pt_tools_postboot_config'] ->
    Class['::pt_profile::pt_source_details']
  }
  elsif $ensure == absent {
    Class['::pt_profile::pt_source_details'] ->
    Class['::pt_profile::pt_samba'] ->
    Class['::io_profile::io_pia'] ->
    Class['::pt_profile::pt_pia'] ->
    Class['::pt_profile::pt_prcs'] ->
    Class['::pt_profile::pt_appserver'] ->
    Class['::pt_profile::pt_psft_environment'] ->
    Class['::pt_profile::pt_tools_deployment'] ->
    Class['::pt_profile::pt_app_deployment'] ->
    Class['::pt_profile::pt_system']
  }
  else {
    fail("Invalid value for 'ensure'. It needs to be either 'present' or 'absent'.")
  }
}
