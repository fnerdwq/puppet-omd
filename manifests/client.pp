# == Class: omd::client
#
# This class installs and configures omd/check_mk checked client.
#
# This works on Debian and RedHat like systems.
# Puppet Version >= 3.4.0
#
# === Parameters
#
# [*check_mk_version*]
#   Version of check_mk-agent to install. Take current Version from
#   <https://mathias-kettner.de/check_mk_download.html>, e.g. '1.2.4p5-1'
#   *MUST*
#
# [*check_only_from*]
#   Ipadresses/networks that check_mk over xinetd accepps access from.
#   defaults to _undef_
#
# [*check_agent*]
#   Binary which does the checks
#   defaults to _/usr/bin/check_mk_
#
# [*export*]
#   Should the clients be exported?
#   defaults to _false_
#
# [*site*]
#   OMD site to export the clients to (must be set if export is true)
#   defaults to _undef_
#
# [*folder*]
#   Folder were exported clients are collected to.
#   defaults to _collected_clients_
#
# === Examples
#
# include omd
#
# === Authors
#
# Frederik Wagner <wagner@wagit.de>
#
# === Copyright
#
# Copyright 2014 Frederik Wagner
#
class omd::client (
  $check_mk_version,
  $check_only_from = $omd::client::params::check_only_from,
  $check_agent     = $omd::client::params::check_agent,
  $export          = $omd::client::params::export,
  $site            = $omd::client::params::site,
  $folder          = $omd::client::params::folder,
) inherits omd::client::params {
  validate_string($check_mk_version)
  validate_string($check_only_from)
  validate_absolute_path($check_agent)
  validate_bool($export)

  contain omd::client::install
  contain omd::client::config

  Class['omd::client::install'] ->
  Class['omd::client::config']

  if $export {
    validate_re($site, '^\w+$')
    validate_re($folder, '^\w+$')

    @@omd::client::export{ "${site} - ${::fqdn}":
      folder => $folder,
      tag    => "omd_client_site_${site}"
    }
  }

}
