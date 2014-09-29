# (private) installs a omd::client
class omd::client::install {

  $download_source = 'http://mathias-kettner.de/download'

  case $::osfamily {
    'Debian': {

      $filename = "check-mk-agent_${omd::client::check_mk_version}_all.deb"

      staging::file { $filename:
        source => "${download_source}/${filename}",
        before => Package['check_mk-agent'],
      }

      $pkg_source   = "/opt/staging/omd/${filename}"
      $pkg_provider = 'dpkg'
      $pkg_name     = 'check-mk-agent'

    }
    'RedHat': {

      $pkg_source   = "${download_source}/check_mk-agent-${omd::client::check_mk_version}.noarch.rpm"
      $pkg_provider = 'rpm'
      $pkg_name     = 'check_mk-agent'

    }
    default: {
      fail("${::osfamily} not supported")
    }
  }

  package { 'check_mk-agent':
    ensure   => installed,
    name     => $pkg_name,
    source   => $pkg_source,
    provider => $pkg_provider,
  }

}
