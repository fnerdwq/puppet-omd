# (private) defaults for omd::client
class omd::client::params {

  $conf_dir         = '/etc/check_mk'
  $mrpe_config      = "${conf_dir}/mrpe.cfg"
  $plugin_path      = '/usr/local/lib'

  $download_package = true
  $download_source  = 'http://mathias-kettner.de/download'
  $logwatch_install = false
  $xinetd_disable   = 'no'
  $check_only_from  = undef
  $check_agent      = '/usr/bin/check_mk_agent'
  $hosts            = { 'default' => {} }
  $hosts_defaults   = {}

  $user             = 'root'
  $group            = 'root'

  case $::osfamily {
    'Debian': {
      $package_name = 'check-mk-agent'
    }
    'RedHat': {
      $package_name = 'check_mk-agent'
    }
    default: {
      fail("${::osfamily} not supported")
    }
  }

}
