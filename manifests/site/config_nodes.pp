# (private) collects and configures nodes in check_mk
define omd::site::config_nodes (
  $folder
) {
  validate_re($folder, '^\w+$')

  $wato_dir   = "/opt/omd/sites/${name}/etc/check_mk/conf.d/wato"
  $hosts_file = "${wato_dir}/${folder}/hosts.mk"

  file { "${wato_dir}/${folder}":
    ensure => directory,
    owner  => $name,
    group  => $name,
    mode   => '0770',
  }

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

# TODO notification of check_mk -I or similar

  Omd::Node::Export <<| tag == "omd_node_site_${name}_folder_${folder}" |>>

  exec { "check_mk update site ${name}":
    command     => "su - ${name} -c 'check_mk -O'",
    refreshonly => true,
    subscribe   => Concat[$hosts_file],
  }

}
