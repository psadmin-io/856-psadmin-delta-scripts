$index_html_template = @(END)
<html>
  <head>
    <title>COMET</title>
    <META http-equiv="refresh" content="0;URL='<%= @root_signon_url %>'" />
  </head>
  <body>
  </body>
</html>
END

$pia_domain_list = hiera('pia_domain_list')
if $pia_domain_list {
  $pia_domain_list.each |$domain_name, $pia_domain_info| {

    $base_web_path = "${pia_domain_info['ps_cfg_home_dir']}/webserv/${domain_name}/applications/peoplesoft/PORTAL.war"
    $webserver_settings = $pia_domain_info['webserver_settings']
    $http_port = $webserver_settings['webserver_http_port']
    $root_signon_url = "http://${::fqdn}:${http_port}/ps/signon.html"

    file { "${base_web_path}/index.html":
        ensure  => file,
        content => inline_template($index_html_template),
      }
  }
}
