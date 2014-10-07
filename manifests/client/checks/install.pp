# (private) install checks
class omd::client::checks::install {

  $plugin_path = $omd::client::checks::params::plugin_path

  File {
    owner  => 'root',
    group  => 'root',
    mode   => '0755',
  }

  # create dir for plugins
  $plugin_dirs = prefix(['/nagios', '/nagios/plugins'], $plugin_path)
  file { $plugin_dirs:
    ensure => directory,
  }

  # install checks
  file { 'check_puppet':
    path   => "${plugin_path}/nagios/plugins/check_puppet.rb",
    source => 'puppet:///modules/omd/checks/check_puppet.rb',
  }

  file { 'check_cert':
    path   => "${plugin_path}/nagios/plugins/check_cert.rb",
    source => 'puppet:///modules/omd/checks/check_cert.rb',
  }

}
