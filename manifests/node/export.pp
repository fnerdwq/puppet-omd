# (private) defines an exported node for inclusion in omd checks
define omd::node::export (
  $folder
) {
  validate_re($folder, '^\w+$')

  $splitted_name = split($name, ' - ')

  $site   = $splitted_name[0]
  $fqdn   = $splitted_name[1]

  validate_re($site, '^\w+$')
  validate_re($fqdn, '^([a-zA-Z0-9-]+\.)+[a-zA-Z0-9-]+$')

  $wato_dir   = "/omd/sites/${site}/etc/check_mk/conf.d/wato"
  $hosts_file = "${wato_dir}/${folder}/hosts.mk"

  concat::fragment { "${site} site's ${folder}/hosts.mk entry for ${fqdn}":
    target  => $hosts_file,
    content => "  \"${fqdn}|puppet_generated\",\n",
    backup  => false,
    order   => 10,
  }

  exec { "check_mk inventorize ${fqdn} for site ${site}":
    command     => "su - ${site} -c 'check_mk -I ${fqdn}'",
    refreshonly => true,
    subscribe   => Concat[$hosts_file],
    before      => Exec["check_mk update site ${site}"],
  }


}
