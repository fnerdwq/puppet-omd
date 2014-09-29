# == Class: omd::client
#
# This class installs and configures omd/check_mk checked client.
#
# This works on Debian and RedHat like systems.
# Puppet Version >= 3.4.0
#
# === Parameters
#
# [*folder*]
#   Folder in which the hosts are collected (must be created with omd::site)
#   defaults to _collected_hosts_
#
# [*check_only_from*]
#   Ipadresses/networks that check_mk over xinetd accepps access from.
#   defaults to _undef_
#
# [*check_agent*]
#   Binary which does the checks
#   defaults to _/usr/bin/check_mk_
#
# === Examples
#
# omd::host { 'site_name': }
#
# === Authors
#
# Frederik Wagner <wagner@wagit.de>
#
# === Copyright
#
# Copyright 2014 Frederik Wagner
#
define omd::host (
  $folder = 'collected_hosts',
  $tags   = [],
) {
  validate_re($name, '^\w+$')
  # folder/tags are validated in subclass omd::client::export

  require 'omd::client'

  @@omd::host::export{ "${name} - ${::fqdn}":
    folder => $folder,
    tags   => $tags,
    tag    => "omd_client_site_${name}_folder_${folder}",
  }

}
