# (private) omd::service resource
define omd::service (
  $ensure,
  $reload,
) {
  validate_re($ensure, '^started|stopped$')
  validate_bool($reload)

  Exec {
    path => ['/bin', '/usr/bin']
  }


  if $ensure == 'started' {

    exec { "start omd site: ${name}":
      command => "omd start ${name}",
      unless  => "omd status -b ${name}",
      returns => [0, 2],
    }

    $restart_cmd =  $reload ? {
      true    => 'reload',
      default => 'restart',
    }
    exec { "${restart_cmd} omd site: ${name}":
      command     => "omd ${restart_cmd} ${name}",
      refreshonly => true,
    }

  } else {

    exec { "stop omd site: ${name}":
      command => "omd stop ${name}",
      onlyif  => "omd status -b ${name}",
      returns => [0, 2],
    }

  }

}
