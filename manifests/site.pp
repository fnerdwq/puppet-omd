# == Define: omd::site
#
# This define creates a OMD site.
#
# As default alls hosts exported for this site are collected
# ($config_hosts) for the 'collected_hosts' folder
# ($collected_hosts_folders).
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
# [*config_hosts*]
#   Collect and configure exported hosts for this site.
#   defaults to _true_
#
# [*config_hosts_folders*]
#   Folders in check_mk where to store and automatically collected hosts to.
#   defaults to _['collected_hosts']_
#
# === Examples
#
# omd::site { 'default':
#   config_hosts_folders => ['myhosts', 'myotherhosts']
# }
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
  $ensure               = 'present',
  $uid                  = undef,
  $gid                  = undef,
  $service_ensure       = 'running',
  $service_reload       = false,
  $options              = undef,
  $config_hosts         = true,
  $config_hosts_folders = ['collected_hosts'],
) {
  validate_re($name, '^\w+$')
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
  validate_bool($config_hosts)

  # cannot require omd::server -> creates cyclic dependency
  include omd::server
  require omd::server::install

  Exec {
    path => ['/bin', '/usr/bin']
  }

  # generic to trigger
  exec { "check_mk update site ${name}":
    command     => "su - ${name} -c 'check_mk -O'",
    refreshonly => true,
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

    if $config_hosts {
      validate_array($config_hosts_folders)

      $config_hosts_array = prefix($config_hosts_folders, "${name} - ")

      omd::site::config_hosts { $config_hosts_array:
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
