# == Class: omd::server
#
# This class installs and configures omd.
#
# omd::sites can be directly created.
#
# === Parameters
#
# [*ensure*]
#   Ensure parameter. Common package 'ensure' or version.
#   defaults to _installed_
#
# [*configure_rep*]
#   Install omd repository (or have the packages availabe by other means).
#   defaults to _true_
#
# [*repo*]
#   Which repo to use stable/testing
#   defaults to _stable_
#
# [*sites*]
#   Omd::sites to create, give hash with name and option.
#   defaults to _{ 'default' => {} }_
#
# [*sites_defaults*]
#   Defaults hash for all site to create with $sites.
#   defaults to _{}_
#
# === Examples
#
# class { 'omd::server':
#   sites => {
#     'mysite' => {
#       'options' => { 'DEFAULT_GUI' => 'check_mk' }
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
class omd::server (
  $ensure         = $omd::server::params::ensure,
  $configure_repo = $omd::server::params::configure_repo,
  $repo           = $omd::server::params::repo,
  $sites          = $omd::server::params::sites,
  $sites_defaults = $omd::server::params::sites_defaults,
) inherits omd::server::params {
  validate_re($ensure, ['^installed|latest|absent|purged$',
                        '^\d\.\d\d$'])
  validate_bool($configure_repo)
  validate_re($repo, '^stable|testing$')
  validate_hash($sites)

  contain 'omd::server::install'
  contain 'omd::server::config'

  Class['omd::server::install'] ->
  Class['omd::server::config']

  create_resources('omd::site', $sites, $sites_defaults)

}
