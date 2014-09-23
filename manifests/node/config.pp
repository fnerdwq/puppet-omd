# (private) configures an omd/check_mk node
class omd::node::config {

  xinetd::service { 'check_mk':
    service_type            => 'UNLISTED',
    port                    => 6556,
    server                  => $omd::node::check_agent,
    log_on_success          => '',
    log_on_success_operator => '=',
    only_from               => $omd::node::check_only_from,
  }


}
