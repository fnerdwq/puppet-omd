# (private) install omd for debian like system
class omd::server::install::debian {

  if $omd::server::configure_repo {
    include apt

    $os = downcase($::operatingsystem)
    apt::source { 'omd':
      location => "http://labs.consol.de/repo/${omd::server::repo}/${os}",
      release  => $::lsbdistcodename,
      repos    => 'main',
      key      => {
        'id'      => 'F2F97737B59ACCC92C23F8C7F8C1CA08A57B9ED7',
        # only possible from puppet 3.7: key_content => files('omd/labs.consol.de.pgp.key')
        'content' => template('omd/labs.consol.de.pgp.key')
      },
    }
  }

  $default_pkg_name = $omd::server::repo ? {
    /testing/ => 'omd-daily',
    default   => 'omd',
  }

}
