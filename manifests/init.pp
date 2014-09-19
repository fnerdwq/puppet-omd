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
#   Version of
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
) inherits omd::params {
  validate_re($ensure, ['^installed|latest|absent|purged$', 
                        '^\d\.\d\d$'])

  class {'omd::install': }

}
