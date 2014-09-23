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
#   State of the site /stopped.
#   defaults to _running_
#
# [*service_reload*]
#   Site reload or restart on trigger.
#   defaults to _false_
#
# [*options*]
#   Site configuration hash, e.g. { 'DEFAULT_GUI' => 'check_mk' , ... }
#   defaults to _undef_
#
# [*config_nodes*]
#   Collect and configure exported nodes for this site.
#   defaults to _true_
#
# [*config_nodes_folder*]
#   Folder in check_mk where to store automatically collected nodes.
#   defaults to _collected_nodes_
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
define omd::site  (
  $ensure              = 'present',
  $uid                 = undef,
  $gid                 = undef,
  $service_ensure      = 'running',
  $service_reload      = false,
  $options             = undef,
  $config_nodes        = true,
  $config_nodes_folder = 'collected_nodes',
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
  # $options validation in omd::config
  validate_bool($config_nodes)
  # $config_nodes_* validation in omd::config_nodes

  require omd

  Exec {
    path => ['/bin', '/usr/bin']
  }

  if $ensure == 'present' {

    exec { "create omd site: ${name}":
      command => "omd create ${_uid}${_gid}${name}",
      unless  => "omd sites -b | grep -q '\\<${name}\\>'",
    }

    omd::site::service { $name:
      ensure => $service_ensure,
      reload => $service_reload,
    }

    if $options {
      Exec["create omd site: ${name}"] ->
      omd::site::config { $name: options => $options } ~>
      Omd::Site::Service[$name]
    } else {
      Exec["create omd site: ${name}"] ~>
      Omd::Site::Service[$name]
    }

    if $config_nodes {
      omd::site::config_nodes { $name:
        folder  => $config_nodes_folder,
        require => Omd::Site::Service[$name],
      }
    }

  } else {

    exec { "remove omd site: ${name}":
      command => "yes yes | omd rm --kill ${name}",
      onlyif  => "omd sites -b | grep -q '\\<${name}\\>'",
    }

  }

}
