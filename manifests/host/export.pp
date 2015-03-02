# (private) defines an exported hosts for inclusion in omd checks
define omd::host::export (
  $folder,
  $tags,
  $cluster_member = false,
) {
  validate_re($folder, '^\w+$')
  validate_bool($cluster_member)
  # no $tag validation, can be array or string

  $splitted_name = split($name, ' - ')

  $site   = $splitted_name[0]
  $fqdn   = $splitted_name[1]

  validate_re($site, '^\w+$')
  validate_re($fqdn, '^([a-zA-Z0-9-]+\.)+[a-zA-Z0-9-]+$')

  $wato_dir   = "/omd/sites/${site}/etc/check_mk/conf.d/wato"
  $hosts_file = "${wato_dir}/${folder}/hosts.mk"

  $content_str = join( flatten([$fqdn, 'puppet_generated', $folder, $tags]), '|')

  concat::fragment { "${site} site's ${folder}/hosts.mk entry for ${fqdn} (all_hosts)":
    target  => $hosts_file,
    content => "  \"${content_str}\",\n",
    order   => '05',
    notify  => Exec["check_mk inventorize ${fqdn} for site ${site}"],
  }

  if $cluster_member {
    concat::fragment { "${site} site's ${folder}/hosts.mk entry for ${fqdn} (clusters)":
      target  => $hosts_file,
      content => " \"${fqdn}\",\n",
      order   => '15',
      notify  => Exec["check_mk inventorize ${fqdn} for site ${site}"],
    }
  }

  exec { "check_mk inventorize ${fqdn} for site ${site}":
    command     => "su - ${site} -c 'check_mk -I ${fqdn}'",
    refreshonly => true,
    path        => [ '/bin' ],
    require     => Concat[$hosts_file],
  }

  # add the orderings and reinventorize trigger to the file trigger of the collected
  # checks (actual collecting see server config)
  File <| tag == "omd_client_check_${fqdn}" |> {
    require => Concat[$hosts_file],
    notify  +> Exec["check_mk inventorize ${fqdn} for site ${site}"],
  }

}
