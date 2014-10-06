# (private) collects and configures clients in check_mk
define omd::site::config_hosts {

  $splitted_name = split($name, ' - ')
  $site   = $splitted_name[0]
  $folder = $splitted_name[1]

  validate_re($site, '^\w+$')
  validate_re($folder, '^\w+$')

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

  concat::fragment { "${site} site's ${folder}/hosts.mk header":
    target  => $hosts_file,
    order   => '01',
    content => "### Managed by puppet.\n\n_lock='Puppet generated'\n\nall_hosts += [\n",
  }
    
  concat::fragment { "${site} site's ${folder}/hosts.mk footer":
    target  => $hosts_file,
    order   => '99',
    content => "]\n",
  }

  Omd::Host::Export <<| tag == "omd_host_site_${site}_folder_${folder}" |>> {
    notify => Exec["check_mk update site ${site}"],
  }

}
