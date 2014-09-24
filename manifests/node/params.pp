# (private) defaults for omd::node
class omd::node::params {

  $check_only_from = undef
  $check_agent     = '/usr/bin/check_mk_agent'
  $export          = false
  $site            = undef
  $folder          = 'collected_nodes'

}
