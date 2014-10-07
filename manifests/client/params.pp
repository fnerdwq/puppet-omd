# (private) defaults for omd::client
class omd::client::params {

  $check_only_from = undef
  $check_agent     = '/usr/bin/check_mk_agent'
  $hosts           = { 'default' => {} }
  $hosts_defaults  = {}

}
