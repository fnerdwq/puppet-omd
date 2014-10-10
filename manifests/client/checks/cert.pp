# == Class: omd::client::checks::cert
#
# This class installs a ssl cert check over MRPE.
#
# Check script from: <https://github.com/ripienaar/monitoring-scripts>
#
# === Parameters
#
# [*title/name*]
#  Resource name for MRPE "Cert_$title/$name".
#
# [*path*]
#   Path to certificate file, whereas $title is used for resource
#   description. defaults to _$title/$name_
#
# [*warn*]
#   Warn level in seconds
#   defaults to _2592000_ (30 days)
#
# [*crit*]
#   Critical level in seconds
#   defaults to _604800_ (7 days)
#
# [*options*]
#   Further options of check (see --help)
#   defaults to _''_
#
# === Examples
#
# include omd::client::checks::cert
#
# === Authors
#
# Frederik Wagner <wagner@wagit.de>
#
# === Copyright
#
# Copyright 2014 Frederik Wagner
#
define omd::client::checks::cert (
  $warn    = '2592000',
  $crit    = '604800',
  $path    = $name,
  $options = '',
) {
  validate_re($warn, '^\d+$')
  validate_re($crit, '^\d+$')
  validate_absolute_path($path)
  validate_string($options)

  include 'omd::client::checks'

  $name_repl = regsubst($name, '[/\s]', '_', 'G')

  $plugin_path = $omd::client::checks::params::plugin_path
  $content = "Cert_${name_repl}\t${plugin_path}/nagios/plugins/check_cert.rb -w ${warn} -c ${crit} --cert ${path} ${options}\n"
  concat::fragment { "check_cert_${name_repl}":
    target  => $omd::client::checks::params::mrpe_config,
    content => $content,
    order   => '50',
    require => File['check_cert'],
  }

  # reinventorize trigger if a MRPE check changed
  @@file { "${::puppet_vardir}/omd/check_cert_${name_repl}_${::fqdn}":
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
