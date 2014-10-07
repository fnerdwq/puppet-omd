# (private) configures omdserver
class omd::server::config {

  file { "${::puppet_vardir}/omd":
    ensure => directory,
    owner  => 'root',
    group  => 'root',
    mode   => '0755',
  }

  # collect all reinveontorize triggers from alls
  # managed MRPE checks
  # (site reload trigger is added in the host export)
  File <<| tag == 'omd_client_checks' |>>
}
