# (private) collects and configures clients in check_mk
define omd::site::config_hosts (
  $cluster      = false,
  $cluster_tags = [],
) {

  $splitted_name = split($name, ' - ')
  $site   = $splitted_name[0]
  $folder = $splitted_name[1]

  validate_re($site, '^\w+$')
  validate_re($folder, '^\w+$')

  validate_bool($cluster)
  validate_array($cluster_tags)

  $wato_dir   = "/omd/sites/${site}/etc/check_mk/conf.d/wato"
  $hosts_file = "${wato_dir}/${folder}/hosts.mk"

  file { "${wato_dir}/${folder}":
    ensure => directory,
    owner  => $site,
    group  => $site,
    mode   => '0770',
  }

  # get all resources/nodess wich are exported for this site/folder from PuppetDB
  $num_hosts = count(query_nodes("Omd::Host[${site}]{folder=${folder}}"))
  file { "${site} site\'s ${folder}/.wato file":
    ensure  => present,
    path    => "${wato_dir}/${folder}/.wato",
    owner   => $site,
    group   => $site,
    mode    => '0660',
    content => template('omd/config_hosts.wato.erb'),
  }

  concat { $hosts_file:
    ensure => present,
    owner  => $site,
    group  => $site,
    mode   => '0660',
  }

  concat::fragment { "${site} site's ${folder}/hosts.mk all_hosts begin":
    target  => $hosts_file,
    order   => '01',
    content => "### Managed by puppet.\n\n_lock='Puppet generated'\n\nall_hosts += [\n",
  }

  concat::fragment { "${site} site's ${folder}/hosts.mk all_hosts end":
    target  => $hosts_file,
    order   => '09',
    content => "]\n\n",
  }

  if ! $cluster {
    # adde multiline column (mieser Trick ;-)
    concat::fragment { "${site} site's ${folder}/hosts.mk COMMENT OUT clusters begin":
      target  => $hosts_file,
      order   => '10',
      content => "'''\n",
    }
    concat::fragment { "${site} site's ${folder}/hosts.mk COMMENT OUT clusters end":
      target  => $hosts_file,
      order   => '19',
      content => "'''\n",
    }
  }

  $cluster_str = join( flatten([$folder, 'puppet_generated', 'cluster', $cluster_tags]), '|')
  concat::fragment { "${site} site's ${folder}/hosts.mk clusters begin":
    target  => $hosts_file,
    order   => '11',
    content => "clusters.update({\n\"${cluster_str}\": [\n",
  }

  concat::fragment { "${site} site's ${folder}/hosts.mk clusters end":
    target  => $hosts_file,
    order   => '18',
    content => "] })\n",
  }

  Omd::Host::Export <<| tag == "omd_host_site_${site}_folder_${folder}" |>>

}
