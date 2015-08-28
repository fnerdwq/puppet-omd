source 'https://rubygems.org'

puppetversion = ENV.key?('PUPPET_VERSION') ? "= #{ENV['PUPPET_VERSION']}" : ['>= 3.2']

group :development, :test do
  gem 'puppet-lint', '> 1.0.0'

  gem 'rspec', '< 3.0.0'
  gem 'rspec-puppet', :git => 'https://github.com/rodjek/rspec-puppet'
  gem 'puppetlabs_spec_helper'
  gem 'rspec-puppet-utils'

#  gem 'beaker'
#  gem 'beaker-rspec'
end

gem 'puppet', puppetversion
