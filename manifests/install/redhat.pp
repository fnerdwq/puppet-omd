# (private) install omd for redhat like systems
class omd::install::redhat {

  include 'epel'

  $rhel_ver = "rhel${::operatingsystemmajrelease}"
  # architecture irrelevant -> noarch
  package{ 'omd-repository':
    ensure   => latest,
    name     => 'labs-consol-stable',
    source   => "https://labs.consol.de/repo/stable/${rhel_ver}/i386/labs-consol-stable.${rhel_ver}.noarch.rpm",
    provider => rpm,
  }
}
