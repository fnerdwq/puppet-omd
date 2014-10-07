# == Class: omd::client::check
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
class omd::client::check inherits omd::client::check::params {

  require omd::client

  contain omd::client::check::install
  contain omd::client::check::config

  Class['omd::client::check::install'] ->
  Class['omd::client::check::config']

}
