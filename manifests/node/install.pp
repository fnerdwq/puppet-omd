# (private) installs a omd::node
class omd::node::install {

  $download_source = 'https://mathias-kettner.de/download'

  case $::osfamily {
    'Debian': {

      $filename = "check-mk-agent_${omd::node::check_mk_version}_all.deb"

      staging::file { $filename:
        source => "${download_source}/${filename}",
        before => Package['check_mk-agent'],
      }

      $pkg_source   = "/opt/staging/omd/${filename}"
      $pkg_provider = 'dpkg'

    }
    'RedHat': {

      $pkg_source   = "${download_source}/check_mk-agent-${omd::node::check_mk_version}.noarch.rpm"
      $pkg_provider = 'rpm'

    }
    default: {
      fail("${::osfamily} not supported")
    }
  }

  package { 'check_mk-agent':
    ensure   => installed,
    source   => $pkg_source,
    provider => $pkg_provider,
  }

}
