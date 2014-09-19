# (private) installs omd
class omd::install {

  $osfamily = downcase($osfamily)
  $install_class = "omd::install::${osfamily}"

  contain $install_class

  case $omd::ensure {
    /\d\.\d\d/: {
      $pkg_ensure = 'present'
      $pkg_name   = "omd-${omd::ensure}"
    }
    default:    { 
      $pkg_ensure = $omd::ensure
      $pkg_name   = 'omd'
    }
  }

  package { 'omd':
    ensure  => $pkg_ensure,
    name    => $pkg_name,
    require => Class[$install_class]
  }


}
