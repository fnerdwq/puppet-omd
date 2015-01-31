# (private) install omd for redhat like systems
class omd::server::install::redhat {

  if $omd::server::configure_repo {
    include 'epel'

    $rhel_ver = "rhel${::operatingsystemmajrelease}"
    # architecture irrelevant -> noarch
    package{ 'omd-repository':
      ensure   => latest,
      name     => "labs-consol-${omd::server::repo}",
      source   => "https://labs.consol.de/repo/${omd::server::repo}/${rhel_ver}/i386/labs-consol-${omd::server::repo}.${rhel_ver}.noarch.rpm",
      provider => rpm,
    }
  }

  $default_pkg_name ='omd'
}
