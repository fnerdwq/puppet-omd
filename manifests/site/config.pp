# (private) omd::site::config resource
define omd::site::config (
  $options
) {
  validate_hash($options)

  $key_vals = join_keys_to_values($options, ' = ')
  $option_strings = prefix($key_vals, "${name} - ")

  omd::site::config_variable { $option_strings: }
  
}
