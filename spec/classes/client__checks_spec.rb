require 'spec_helper'

describe 'omd::client::checks' do

  #################################
  # default is Debian environment #
  #################################

  # we need to set the must parameter
  let(:pre_condition) { 'class omd::client { $check_mk_version = "1.2.3" }' }

  it { is_expected.to contain_class('omd::client').that_comes_before('omd::client::checks') }

  it { is_expected.to contain_class('omd::client::checks::params') }
  it { is_expected.to contain_class('omd::client::checks::install') }
  it { is_expected.to contain_class('omd::client::checks::config')\
         .that_requires('omd::client::checks::install') }

  describe 'installation' do

    it do
      is_expected.to contain_file('/usr/local/lib/nagios').with({
        :ensure => 'directory',
        :owner  => 'root',
        :group  => 'root',
        :mode   => '0755',
      })
    end
    it do
      is_expected.to contain_file('/usr/local/lib/nagios/plugins').with({
        :ensure => 'directory',
        :owner  => 'root',
        :group  => 'root',
        :mode   => '0755',
      })
    end

    it do
      is_expected.to contain_file("check_puppet").with({
        :path   => '/usr/local/lib/nagios/plugins/check_puppet.rb',
        :source => 'puppet:///modules/omd/checks/check_puppet.rb',
        :owner  => 'root',
        :group  => 'root',
        :mode   => '0755',
      })
   end

   it do
     is_expected.to contain_file("check_cert").with({
       :path   => '/usr/local/lib/nagios/plugins/check_cert.rb',
       :source => 'puppet:///modules/omd/checks/check_cert.rb',
       :owner  => 'root',
       :group  => 'root',
       :mode   => '0755',
     })
   end

  end

  describe 'configuration' do
    it do
      is_expected.to contain_concat('/etc/check_mk/mrpe.cfg').with({
        :ensure => 'present',
        :owner  => 'root',
        :group  => 'root',
        :mode   => '0644',
      })
    end
    it do
      is_expected.to contain_concat__fragment('mrpe.cfg header').with({
        :target  => '/etc/check_mk/mrpe.cfg',
        :order   => '01',
        :content => "### Managed by puppet.\n\n",
      })
    end

  end

end
