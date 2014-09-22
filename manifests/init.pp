# == Class: omd
#
# This class installs and configures omd.
#
# This works on Debian and RedHat like systems.
# Puppet Version >= 3.4.0
#
# === Parameters
#
# [*ensure*]
#   Ensure parameter. Common package 'ensure' or version.
#   defaults to _installed_
#
# [*repo*]
#   Which repo to use stable/testing
#   defaults to _stable_
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
class omd (
  $ensure = $omd::params::ensure,
  $repo   = $omd::params::repo,
) inherits omd::params {
  validate_re($ensure, ['^installed|latest|absent|purged$', 
                        '^\d\.\d\d$'])
  validate_re($repo, '^stable|testing$')

  contain 'omd::install'

}
