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
      # inline template, as long as lookup() only in future_parser (or in module hiera?)
      # take default_pkg_name set in osfamily specific class
      $pkg_name   = inline_template('<%= scope[@install_class + "::default_pkg_name"] -%>')
    }
  }

  package { 'omd':
    ensure  => $pkg_ensure,
    name    => $pkg_name,
    require => Class[$install_class]
  }


}
