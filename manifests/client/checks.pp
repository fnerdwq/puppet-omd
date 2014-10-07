# == Class: omd::client::checks
#
# This class installs and configures extra nagios checks.
#
# Does not need to be included directly.
#
# === Parameters
#
# none
#
# === Examples
#
# none
#
# === Authors
#
# Frederik Wagner <wagner@wagit.de>
#
# === Copyright
#
# Copyright 2014 Frederik Wagner
#
class omd::client::checks inherits omd::client::checks::params {

  require omd::client

  contain omd::client::checks::install
  contain omd::client::checks::config

  Class['omd::client::checks::install'] ->
  Class['omd::client::checks::config']

}
