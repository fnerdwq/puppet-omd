# == Define: omd::site
#
# This define creates a OMD site.
#
# This works on Debian and RedHat like systems.
# Puppet Version >= 3.4.0
#
# === Parameters
#
# [*ensure*]
#   Site present or absent.
#   defaults to _present_
#
# [*uid*]
#   UID of site user '$name'
#   defaults to _undef_
#
# [*gid*]
#   GID of site group '$name'
#   defaults to _unde
#
# [*service_ensure*]
#   State of the site started/stopped.
#   defaults to _started_
#
# [*service_reload*]
#   Site reload or restart on trigger.
#   defaults to _false_
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
  $ensure         = 'present',
  $uid            = undef,
  $gid            = undef,
  $service_ensure = 'started',
  $service_reload = false,
) {
  validate_re($ensure, '^present|absent$')
  if $uid {
    validate_re($uid, '\d+')
    $_uid = "--uid ${uid} "
  }
  if $gid {
    validate_re($gid, '\d+')
    $_gid = "--gid ${gid} "
  }
  # $service_* validation in omd::service

  require omd

  Exec {
    path => ['/bin', '/usr/bin']
  }

  if $ensure == 'present' {

    exec { "create omd site: ${name}":
      command => "omd create ${_uid}${_gid}${name}",
      unless  => "omd sites -b | grep -q '\\<${name}\\>'",
    }
  
    omd::service{ $name:
      ensure => $service_ensure,
      reload => $service_reload,
    }

  } else {

    exec { "remove omd site: ${name}":
      command => "yes yes | omd rm --kill ${name}",
      onlyif  => "omd sites -b | grep -q '\\<${name}\\>'",
    }

  }

}
