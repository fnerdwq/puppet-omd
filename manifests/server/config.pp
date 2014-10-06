# (private) configures omdserver
class omd::server::config {

  file { "${::puppet_vardir}/omd":
    ensure => directory,
    owner  => 'root',
    group  => 'root',
    mode   => '0755',
  }

}
