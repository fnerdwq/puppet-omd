# == Class: omd::client::checks::mrpe
#
# Installs arbitrary check scripts over MRPE.
#
# === Parameters
#
# [*title/name*]
#  Name of Check.
#
# [*path*]
#   Path to check Script.
#   *required*
#
# [*options*]
#   Options for check Script.
#   defaults to _''_
#
# === Examples
#
# omd::client::checks::mrpe { 'Check_something':
#   path    => '/path/to/check/script.sh',
#   options => '-w warn -c critical',
# }
#
# === Authors
#
# Frederik Wagner <wagner@wagit.de>
#
# === Copyright
#
# Copyright 2015 Frederik Wagner
#
define omd::client::checks::mrpe (
  $path,
  $options = '',
) {
  validate_re($name, '^\w+$')
  validate_absolute_path($path)
  validate_string($options)

  include 'omd::client::checks'

  $content = "${name}\t${path} ${options}\n"
  concat::fragment { "check_mrpe_${name}":
    target  => $omd::client::checks::params::mrpe_config,
    content => $content,
    order   => '50',
  }

  # reinventorize trigger if a MRPE check changed
  @@file { "${::puppet_vardir}/omd/check_mrpe_${name}_${::fqdn}":
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
