# (private) defaults for omd::client
class omd::client::params {

  $check_only_from = undef
  $check_agent     = '/usr/bin/check_mk_agent'
  $export          = false
  $site            = undef
  $folder          = 'collected_clients'

}
