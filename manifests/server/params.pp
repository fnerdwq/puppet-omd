# (private) omd::server defaults
class omd::server::params {

  $ensure          = 'installed'
  $repo            = 'stable'
  $sites           = { 'default' => {} }
  $sites_defaults  = {}

}
