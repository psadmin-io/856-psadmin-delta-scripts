$pia_domain_list = hiera('pia_domain_list')

$pia_domain_list.each | $domain, $pia_domain_info | {
    $ps_cfg_home = $pia_domain_info['ps_cfg_home_dir']
    $portal_home = "${ps_cfg_home}/webserv/${domain}/applications/peoplesoft/PORTAL.war"

    file { "${domain}-healthcheck":
        ensure  => present,
        path    => "$portal_home/health.html",
        content => "true",
    }
}