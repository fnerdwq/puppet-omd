# (private) helper to resolve config_hosts_folders hash in
# omd::site into omd::site::config_hosts calls
define omd::site::helper::config_hosts (
  $configs,
) {

  $splitted_name = split($name, ' - ')
  $site   = $splitted_name[0]
  $folder = $splitted_name[1]

  $config = $configs[$folder]

  validate_re($site, '^\w+$')
  validate_re($folder, '^\w+$')
  validate_hash($config)

  create_resources('omd::site::config_hosts', { "${name}" => $config },
    {
      'require' => "Omd::Site::Service[${site}]",
      'notify' => "Exec[check_mk update site: ${site}]",
    }
  )

}
