# == Class: omd::client::checks::puppet
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
#   defaults to _''_
#
# === Examples
#
# include omd::client::checks::puppet
#
# Default checks for last run time. User option -f with custom warn/crit for
# failures.
#
# === Authors
#
# Frederik Wagner <wagner@wagit.de>
#
# === Copyright
#
# Copyright 2014 Frederik Wagner
#
class omd::client::checks::puppet (
  $warn    = '3600',
  $crit    = '7200',
  $options = '',
) {
  validate_re($warn, '^\d+$')
  validate_re($crit, '^\d+$')
  validate_string($options)

  include 'omd::client::checks'

  $plugin_path = $omd::client::checks::params::plugin_path
  $content = "Puppet_Agent\t${plugin_path}/nagios/plugins/check_puppet.rb -w ${warn} -c ${crit} ${options}\n"
  concat::fragment { 'check_puppet':
    target  => $omd::client::checks::params::mrpe_config,
    content => $content,
    order   => '50',
    require => File['check_puppet'],
  }

  # reinventorize trigger if a MRPE check changed
  @@file { "${::puppet_vardir}/omd/check_puppet_${::fqdn}":
    ensure  => present,
    owner   => root,
    group   => root,
    mode    => '0644',
    content => $content,
    backup  => false,
    # server collection and site inventory trigger tags
    tag     => ['omd_client_checks', "omd_client_check_${::fqdn}"],
  }

}
