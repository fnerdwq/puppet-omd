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
# [*main_mk_content*]
#   Pass arbitrary content for the Check_mk main.mk config file.
#   defaults to _undef_
#
# === Examples
#
# omd::site { 'default':
#   config_hosts_folders => ['myhosts', 'myotherhosts']
# }
#
#  or
#
# omd::site { 'default':
#   config_hosts_folders => {
#     'myhosts' => {
#       'cluster' => true,
#       'clutser_tags' => ['tag1', 'tag2'],
#     }
#   }
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
  $main_mk_content      = undef,
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
  exec { "check_mk update site: ${name}":
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

      if is_array($config_hosts_folders) {
        $config_hosts_array = prefix($config_hosts_folders, "${name} - ")

        omd::site::config_hosts { $config_hosts_array:
          require => Omd::Site::Service[$name],
          notify  => Exec["check_mk update site: ${name}"],
        }

      } elsif is_hash($config_hosts_folders) {

        $config_hosts_array = prefix(keys($config_hosts_folders), "${name} - ")

        omd::site::helper::config_hosts { $config_hosts_array:
          configs => $config_hosts_folders,
        }

      } else {
        fail('$config_hosts_folders must be either an Array or Hash')
      }
    }

    if $main_mk_content {
      validate_string($main_mk_content)

      file { "/omd/sites/${name}/etc/check_mk/main.mk":
        ensure  => present,
        owner   => $name,
        group   => $name,
        mode    => '0644',
        content => $main_mk_content,
        notify  => Exec["check_mk update site: ${name}"],
      }
    }

  } else {

    exec { "remove omd site: ${name}":
      command => "yes yes | omd rm --kill ${name}",
      onlyif  => "omd sites -b | grep -q '\\<${name}\\>'",
    }

  }

}
