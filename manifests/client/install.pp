# (private) installs a omd::client
class omd::client::install {

  if $omd::client::download_package {
    $download_source = "${omd::client::download_source}"

    case $::osfamily {
      'Debian': {

        $pkg_agent    = "check-mk-agent_${omd::client::check_mk_version}_all.deb"
        $pkg_logwatch = "check-mk-agent-logwatch_${omd::client::check_mk_version}_all.deb"

        staging::file { $pkg_agent:
          source => "${download_source}/${pkg_agent}",
          before => Package['check_mk-agent'],
        }

        if $omd::client::logwatch_install {

          staging::file { $pkg_logwatch:
            source => "${download_source}/${pkg_logwatch}",
            before => Package['check_mk-agent-logwatch'],
          }

        }

        $pkg_source_agent    = "/opt/staging/omd/${pkg_agent}"
        $pkg_source_logwatch = "/opt/staging/omd/${pkg_logwatch}"
        $pkg_provider        = 'dpkg'

      }
      'RedHat': {

        $pkg_source_agent    = "${download_source}/check_mk-agent-${omd::client::check_mk_version}.noarch.rpm"
        $pkg_source_logwatch = "${download_source}/check_mk-agent-logwatch-${omd::client::check_mk_version}.noarch.rpm"
        $pkg_provider        = 'rpm'

      }
      default: {
        fail("${::osfamily} not supported")
      }
    }
  } else {
    $pkg_source_agent    = undef
    $pkg_source_logwtach = undef
    $pkg_provider        = undef
  }

  # some packages (e.g. CentOS 7) do not create directory
  file { '/etc/check_mk':
    ensure => directory,
    owner  => $omd::client::user,
    group  => $omd::client::group,
    mode   => '0755',
  }

  package { 'check_mk-agent':
    ensure   => installed,
    name     => $omd::client::package_name,
    source   => $pkg_source_agent,
    provider => $pkg_provider,
    require  => File['/etc/check_mk'],
  }

  if $omd::client::logwatch_install {
    package { 'check_mk-agent-logwatch':
      ensure   => installed,
      name     => "${omd::client::package_name}-logwatch",
      source   => $pkg_source_logwatch,
      provider => $pkg_provider,
      require  => [ Package['check_mk-agent'],
                    File['/etc/check_mk'], ],
    }

    file { '/etc/check_mk/logwatch.cfg':
      ensure  => present,
      owner   => $omd::client::user,
      group   => $omd::client::group,
      mode    => '0644',
      content => "# Managed by puppet.\n\n# See logwatch.d/*.cfg for configuration.\n",
    }

    file { '/etc/check_mk/logwatch.d':
      ensure => directory,
      owner  => $omd::client::user,
      group  => $omd::client::group,
      mode   => '0755',
    }

  }

}
