# (private) configures an omd/check_mk client
class omd::client::config {

  xinetd::service { 'check_mk':
    service_type            => 'UNLISTED',
    port                    => 6556,
    server                  => $omd::client::check_agent,
    log_on_success          => '',
    log_on_success_operator => '=',
    only_from               => $omd::client::check_only_from,
  }

  concat { $omd::client::params::mrpe_config:
    ensure => present,
    owner  => 'root',
    group  => 'root',
    mode   => '0644',
  }

  concat::fragment { 'mrpe.cfg header':
    target  => $omd::client::params::mrpe_config,
    order   => '01',
    content => "### Managed by puppet.\n\n",
  }


}
