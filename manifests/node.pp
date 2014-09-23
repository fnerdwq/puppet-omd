# == Class: omd::node
#
# This class installs and configures omd/check_mk checked node.
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
class omd::node (
  $check_mk_version
) {
  validate_string($check_mk_version)
  
  contain omd::node::install
  contain omd::node::config

  Class['omd::node::install'] ->
  Class['omd::node::config']

}
