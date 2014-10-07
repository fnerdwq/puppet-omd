# (private) configure checks
class omd::client::checks::config {

  concat { $omd::client::checks::params::mrpe_config:
    ensure => present,
    owner  => 'root',
    group  => 'root',
    mode   => '0644',
  }

  # create mrpe.cfg stub
  concat::fragment { 'mrpe.cfg header':
    target  => $omd::client::checks::params::mrpe_config,
    order   => '01',
    content => "### Managed by puppet.\n\n",
  }

}
