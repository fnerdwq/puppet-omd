# (private) install omd for debian like system
class omd::server::install::debian {

  include apt

  $os = downcase($::operatingsystem)
  apt::source { 'omd':
    location    => "http://labs.consol.de/repo/${omd::server::repo}/${os}",
    release     => $::lsbdistcodename,
    repos       => 'main',
    key         => 'F8C1CA08A57B9ED7',
    # geht so leider erst ab puppet 3.7
    #key_content => files('omd/labs.consol.de.pgp.key'),
    key_content => template('omd/labs.consol.de.pgp.key'),
    include_src => false,
  }

  $default_pkg_name = $omd::server::repo ? {
    /testing/ => 'omd-daily',
    default   => 'omd',
  }

}
