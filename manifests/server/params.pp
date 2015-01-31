# (private) omd::server defaults
class omd::server::params {

  $ensure          = 'installed'
  $configure_repo  = true
  $repo            = 'stable'
  $sites           = { 'default' => {} }
  $sites_defaults  = {}

}
