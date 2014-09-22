# (private) install omd for redhat like systems
class omd::install::redhat {

  include 'epel'

  $rhel_ver = "rhel${::operatingsystemmajrelease}"
  # architecture irrelevant -> noarch
  package{ 'omd-repository':
    ensure   => latest,
    name     => "labs-consol-${omd::repo}",
    source   => "https://labs.consol.de/repo/${omd::repo}/${rhel_ver}/i386/labs-consol-${omd::repo}.${rhel_ver}.noarch.rpm",
    provider => rpm,
  }
 
  $default_pkg_name ='omd'
}
