class io_profile::io_pia {
  notify { "Applying io_profile::io_pia": }


  $index_html_template = @(END)
<html>
  <head>
    <title>PeopleSoft</title>
    <META http-equiv="refresh" content="0;URL='<%= @root_signon_url %>'" />
  </head>
  <body>
  </body>
</html>
END

  $pia_domain_list = hiera('pia_domain_list')
  if $pia_domain_list {
    $pia_domain_list.each |$domain_name, $pia_domain_info| {

      $ps_cfg_home = $pia_domain_info['ps_cfg_home_dir']
      $portal_home = "${ps_cfg_home}/webserv/${domain_name}/applications/peoplesoft/PORTAL.war"
      
      file { "${domain}-healthcheck":
          ensure  => present,
          path    => "${portal_home}/health.html",
          content => "true",
      }

      $webserver_settings = $pia_domain_info['webserver_settings']
      $http_port = $webserver_settings['webserver_http_port']
      $root_signon_url = "http://${::fqdn}:${http_port}/ps/signon.html"

      file { "${portal_home/index.html":
          ensure  => file,
          content => inline_template($index_html_template),
        }

    }
  }

}
