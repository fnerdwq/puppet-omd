# (private) collects and configures nodes in check_mk
define omd::site::config_nodes (
  $folder
) {
  validate_re($folder, '^\w+$')

  $wato_dir   = "/omd/sites/${name}/etc/check_mk/conf.d/wato"
  $hosts_file = "${wato_dir}/${folder}/hosts.mk"

  file { "${wato_dir}/${folder}":
    ensure => directory,
    owner  => $name,
    group  => $name,
    mode   => '0770',
  }

  # get all resources/nodes wich are exported for this site/folder from PuppetDB
  $num_hosts = count(query_nodes("Class[Omd::Node]{export=true and site=${name} and folder=${folder}}"))
  file { "${name} site\'s ${folder}/.wato file":
    ensure  => present,
    path    => "${wato_dir}/${folder}/.wato",
    owner   => $name,
    group   => $name,
    mode    => '0660',
    content => template('omd/config_nodes.wato.erb'),
  }

  concat { $hosts_file:
    ensure => present,
    owner  => $name,
    group  => $name,
    mode   => '0660',
  }

  concat::fragment { "${name} site's ${folder}/hosts.mk header":
    target  => $hosts_file,
    order   => '01',
    content => "### Managed by puppet.\n\n_lock='Puppet generated'\n\nall_hosts += [\n",
  }
    
  concat::fragment { "${name} site's ${folder}/hosts.mk footer":
    target  => $hosts_file,
    order   => '99',
    content => "]\n",
  }

  Omd::Node::Export <<| tag == "omd_node_site_${name}" |>>

  exec { "check_mk update site ${name}":
    command     => "su - ${name} -c 'check_mk -O'",
    refreshonly => true,
    subscribe   => Concat[$hosts_file],
  }

}
