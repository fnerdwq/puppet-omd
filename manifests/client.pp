# == Class: omd::client
#
# This class installs and configures omd/check_mk checked client.
#
# The client can be automatically exported as omd::host to one or many
# omd::sites.
#
# === Parameters
#
# [*check_mk_version*]
#   Version of check_mk-agent to install. Take current Version from
#   <https://mathias-kettner.de/check_mk_download.html>, e.g. '1.2.4p5-1'
#   *MUST*
#
# [*package_name*]
#   Name of Check MK Package override
#   depends on ::osfamily
#
# [*download_source*]
#   Where to download the install package from.
#   defaults to _http://mathias-kettner.de/download_
#
# [*download_package*]
#   Whether to download package or have it available by other means.
#   defaults to _true_
#
# [*logwatch_install*]
#   Wheter to install logwatch plugin for check_mk-agent.
#   defaults to _false_
#
# [*xinetd_disable*]
#   Disable check_mk-agent acces via xinetd.
#   defaults to _no_
#
# [*check_only_from*]
#   Ipadresses/networks that check_mk over xinetd accepps access from.
#   defaults to _undef_
#
# [*check_agent*]
#   Binary which does the checks
#   defaults to _/usr/bin/check_mk_
#
# [*hosts*]
#   Omd::hosts to export, give hash with sitename and options.
#   defaults to _{ 'default' => {} }_
#
# [*hosts_defaults*]
#   Defaults hash for all hosts to create with $hosts.
#   defaults to _{}_
#
# [*user*]
#   User which owns the check_mk-agent config files.
#   defaults to _root_
#
# [*group*]
#   Group of check_mk-agent config files.
#   defaults to _root_
#
# === Examples
#
# class { 'omd::client':
#   check_mk_version => '1.2.4p5-1',
#   hosts            => { 'site' => { folder => 'myhosts' } }
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
class omd::client (
  $check_mk_version,
  $package_name     = $omd::client::params::package_name,
  $download_source  = $omd::client::params::download_source,
  $download_package = $omd::client::params::download_package,
  $logwatch_install = $omd::client::params::logwatch_install,
  $xinetd_disable   = $omd::client::params::xinetd_disable,
  $check_only_from  = $omd::client::params::check_only_from,
  $check_agent      = $omd::client::params::check_agent,
  $hosts            = $omd::client::params::hosts,
  $hosts_defaults   = $omd::client::params::hosts_defaults,
  $user             = $omd::client::params::user,
  $group            = $omd::client::params::group,
) inherits omd::client::params {
  validate_string($check_mk_version)
  validate_string($package_name)
  validate_string($download_source)
  validate_bool($download_package)
  validate_re($xinetd_disable, ['^yes$','^no$'])
  validate_string($check_only_from)
  validate_absolute_path($check_agent)
  validate_hash($hosts)
  validate_string($user)
  validate_string($group)

  contain omd::client::install
  contain omd::client::config

  Class['omd::client::install'] ->
  Class['omd::client::config']

  create_resources('omd::host', $hosts, $hosts_defaults)

}
