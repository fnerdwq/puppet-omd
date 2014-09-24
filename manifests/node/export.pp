# (private) exports node for inclusion in omd checks
class omd::node::export {

  $wato_dir   = "/opt/omd/sites/${omd::node::site}/etc/check_mk/conf.d/wato"
  $hosts_file = "${wato_dir}/${omd::node::folder}/hosts.mk"

  @@concat::fragment { "default site's hostmk entry for ${::fqdn}":
    target  => $hosts_file,
    content => "${::fqdn}|puppet_generated",
    backup  => false,
    order   => 10,
    tag     => 'omd_noded_site_default',
  }


}
