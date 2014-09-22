# (private) omd::site::service resource
define omd::site::service (
  $ensure,
  $reload,
) {
  validate_re($ensure, '^running|stopped$')
  validate_bool($reload)

  Exec {
    path => ['/bin', '/usr/bin']
  }


  if $ensure == 'running' {

    $restart_cmd =  $reload ? {
      true    => 'reload',
      default => 'restart',
    }
    # only restart when started (otherwise exec 'start', starts)
    exec { "${restart_cmd} omd site: ${name}":
      command     => "omd ${restart_cmd} ${name}",
      onlyif      => "omd status -b ${name}",
      refreshonly => true,
    }

    # restart, in case 
    exec { "start omd site: ${name}":
      command => "omd start ${name}",
      unless  => "omd status -b ${name}",
      returns => [0, 2],
    }


  } else {

    exec { "stop omd site: ${name}":
      command => "omd stop ${name}",
      onlyif  => "omd status -b ${name}",
      returns => [0, 2],
    }

  }

}
