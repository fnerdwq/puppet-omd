require 'puppetlabs_spec_helper/module_spec_helper'
require 'rspec-puppet-utils'

# coverage test at the end
#at_exit { RSpec::Puppet::Coverage.report! }

RSpec.configure do |c|
#  c.formatter = :documentation

  c.default_facts = {
    :kernel          => 'Linux',
    :osfamily        => 'Debian',
    :operatingsystem => 'Debian',
    :lsbdistid       => 'Debian',
    :lsbdistcodename => 'wheezy',
    :concat_basedir  => '/var/lib/puppet/concat',
  }

end

