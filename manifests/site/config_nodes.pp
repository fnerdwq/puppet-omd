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

  concat { $hosts_file:
    ensure => present,
    owner  => $name,
    group  => $name,
    mode   => '0660',
  }

  concat::fragment { "${name} site's hosts.mk header":
    target  => $hosts_file,
    order   => '01',
    content => "### Managed by puppet.\n\nall_hosts += [\n",
  }
    
  concat::fragment { "${name} site's hosts.mk footer":
    target  => $hosts_file,
    order   => '99',
    content => "]\n",
  }


}
