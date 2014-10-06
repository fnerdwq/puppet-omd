# == Class: omd::client::check::puppet
#
# This class installs a puppet agent check over MRPE.
#
# Check script from: <https://github.com/ripienaar/monitoring-scripts>
#
# === Parameters
#
# [*warn*]
#   Warn level in seconds
#   defaults to _3600_
#
# [*crit*]
#   Critical level in seconds
#   defaults to _7200_
#
# [*options*]
#   Further options of check (see --help)
#   defaults to _-f_
#
# === Examples
#
# include omd::client::check::puppet
#
# === Authors
#
# Frederik Wagner <wagner@wagit.de>
#
# === Copyright
#
# Copyright 2014 Frederik Wagner
#
class omd::client::check::puppet (
  $warn    = '3600',
  $crit    = '7200',
  $options = '-f',
) {
  validate_re($warn, '^\d+$')
  validate_re($crit, '^\d+$')
  validate_string($options)

  include 'omd::client'

  file { 'check_puppet':
    path   => "${omd::client::params::plugin_path}/nagios/plugins/check_puppet.rb",
    source => 'puppet:///modules/omd/checks/check_puppet.rb',
    owner  => 'root',
    group  => 'root',
    mode   => '0755',
  }

  $content = "Puppet_Agent\t${omd::client::params::plugin_path}/nagios/plugins/check_puppet.rb -w ${warn} -c ${crit} ${options}\n"
  concat::fragment { 'check_puppet':
    target  => $omd::client::params::mrpe_config,
    content => $content,
    order   => '50',
    require => File['check_puppet'],
  }

  # reinventorize trigger if a MRPE check changed
  @@file { "${::settings::vardir}/omd/check_puppet_${::fqdn}":
    ensure  => present,
    owner   => root,
    group   => root,
    mode    => '0644',
    content => $content,
    backup  => false,
    tag     => "omd_client_check_${::fqdn}",
  }

}
