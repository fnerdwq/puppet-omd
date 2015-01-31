# (private) defaults for omd::client
class omd::client::params {

  $download_package = true
  $xinetd_disable   = 'no'
  $check_only_from  = undef
  $check_agent      = '/usr/bin/check_mk_agent'
  $hosts            = { 'default' => {} }
  $hosts_defaults   = {}

}
