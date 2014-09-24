# (private) exports node for inclusion in omd checks
class omd::node::export {

  $wato_dir   = "/opt/omd/sites/${omd::node::site}/etc/check_mk/conf.d/wato"
  $hosts_file = "${wato_dir}/${omd::node::folder}/hosts.mk"

  @@concat::fragment { "default site's hostmk entry for ${::fqdn}":
    target  => $hosts_file,
    content => "  \"${::fqdn}|puppet_generated\",\n",
    backup  => false,
    order   => 10,
    tag     => "omd_node_site_${omd::node::site}",
  }


}
