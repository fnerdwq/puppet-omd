# == Class: omd::client::checks::logwatch
#
# Installs log monitoring snippets.
#
# === Parameters
#
# [*content*]
#   Content of check_mk logwatch configuration file.
#   *MUST*
#
# === Examples
#
# omd::client::checks::logwatch { 'somelog':
#   content => '/var/log/somelog
#  C critical.*error
#  C some.*other.*thingy
# ',
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
define omd::client::checks::logwatch (
  $content,
) {
  validate_re($name, '^\w+$')

  include 'omd::client::checks'

  if ! $omd::client::logwatch_install {
    fail('$logwatch_install on omd::client must be true!')
  }

  file { "/etc/check_mk/logwatch.d/${name}.cfg":
    ensure  => present,
    owner   => $omd::client::user,
    group   => $omd::client::group,
    mode    => '0644',
    content => $content,
  }

  # reinventorize trigger if a MRPE check changed
  @@file { "${::puppet_vardir}/omd/check_logwatch_${name}_${::fqdn}":
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
