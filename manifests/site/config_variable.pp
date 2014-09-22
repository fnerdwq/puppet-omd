# (private) omd::site::config_variable resource
define omd::site::config_variable {

  include omd::site::params

  $split = split($name, ' - | = ')

  $site     = $split[0]
  $variable = $split[1]
  $value    = $split[2]

  if !($variable in $omd::site::params::allowed_options) {
    fail("Option ${variable} not in list of allowed options!")
  }

  Exec {
    path => ['/bin', '/usr/bin']
  }

  # site must be stopped for changes
  exec { "config omd site: ${site} - ${variable} = ${value}":
    command => "omd stop ${site}; omd config ${site} set ${variable} ${value}",
    unless  => "omd config ${site} show ${variable} | grep -q '^${value}$'",
  }

}
