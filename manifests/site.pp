# == Define: omd::site
#
# This define creates a OMD site.
#
# This works on Debian and RedHat like systems.
# Puppet Version >= 3.4.0
#
# === Parameters
#
# [*repo*]
#   Which repo to use stable/testing
#   defaults to _stable_
#
# === Examples
#
# omd::site { 'default': }
#
# === Authors
#
# Frederik Wagner <wagner@wagit.de>
#
# === Copyright
#
# Copyright 2014 Frederik Wagner
#
define omd::site (
  $uid            = undef,
  $gid            = undef,
  $service_ensure = 'started',
  $service_reload = false,
) {
  if $uid {
    validate_re($uid, '\d+')
    $_uid = "--uid ${uid} "
  }
  if $gid {
    validate_re($gid, '\d+')
    $_gid = "--gid ${gid} "
  }

  require omd

  Exec {
    path => ['/bin', '/usr/bin']
  }

  exec { "create omd site: ${name}":
    command => "omd create ${_uid}${_gid}${name}",
    unless  => "omd sites -b | grep -q '\\<${name}\\>'",
  }

  omd::service{ $name:
    ensure => $service_ensure,
    reload => $service_reload,
  }

}
