require 'spec_helper'

describe 'omd::node' do

  #################################
  # default is Debian environment #
  #################################
  
  let(:default_params) {{
    :check_mk_version => '1.2.4p5-1'
  }}
  let(:params) { default_params }

  it { is_expected.to contain_class('omd::node::install') }
  it { is_expected.to contain_class('omd::node::config').that_requires('omd::node::install') }
  it { is_expected.not_to contain_class('omd::node::export') }

  describe 'installation' do

    context 'on Debian like systems' do
      it do
        is_expected.to contain_staging__file('check-mk-agent_1.2.4p5-1_all.deb')\
          .with_source('http://mathias-kettner.de/download/check-mk-agent_1.2.4p5-1_all.deb')\
          .that_comes_before('Package[check_mk-agent]')
      end
      it do
        is_expected.to contain_package('check_mk-agent').with({
          :ensure   => 'installed',
          :name     => 'check-mk-agent',
          :source   => '/opt/staging/omd/check-mk-agent_1.2.4p5-1_all.deb',
          :provider => 'dpkg',
        })
      end
    end

    context 'on RedHat like systems' do
      let(:facts) {{
        :osfamily        => 'RedHat',
        :operatingsystem => 'CentOS',
      }}
      it do
        is_expected.to contain_package('check_mk-agent').with({
          :ensure   => 'installed',
          :name     => 'check_mk-agent',
          :source   => 'http://mathias-kettner.de/download/check_mk-agent-1.2.4p5-1.noarch.rpm',
          :provider => 'rpm',
        })
      end
    end

    context 'with parameter check_mk_version => 1.2.3' do
      let(:params) {{ :check_mk_version => '1.2.3' }}
      it { is_expected.to contain_package('check_mk-agent').with_source(/1\.2\.3/) }
    end
    context 'with parameter check_mk_version => [breakme]' do
      let(:params) {{ :check_mk_version => ['breakme'] }}
      it { is_expected.to raise_error(/is not a string/) }
    end

  end

  describe 'configuration' do

    it do
      is_expected.to contain_xinetd__service('check_mk').with({
        :service_type            => 'UNLISTED',
        :port                    => 6556,
        :server                  => '/usr/bin/check_mk_agent',
        :log_on_success          =>  '',
        :log_on_success_operator => '='
      }).without_only_from
    end

    context 'with parameter check_only_from => 192.168.1.1' do
      let(:params) { default_params.merge({ :check_only_from => '192.168.1.1' })}
      it { is_expected.to contain_xinetd__service('check_mk').with_only_from('192.168.1.1') }
    end
    context 'with parameter check_only_from => [breakme]' do
      let(:params) { default_params.merge({ :check_only_from => ['breakme'] })}
      it { is_expected.to raise_error(/is not a string/) }
    end

    context 'with parameter check_agent => /usr/bin/check_mk_caching_agent' do
      let(:params) { default_params.merge({ :check_agent => '/usr/bin/check_mk_caching_agent' })}
      it { is_expected.to contain_xinetd__service('check_mk').with_server('/usr/bin/check_mk_caching_agent') }
    end
    context 'with parameter check_agent => brea kme' do
      let(:params) { default_params.merge({ :check_agent => 'brea kme' })}
      it { is_expected.to raise_error(/is not an absolute path/) }
    end

  end

  describe 'export' do
    # external resources cannot be tested

    context "with parameter export => true, site => default" do
      let(:params) { default_params.merge({
        :export => true,
        :site   => 'default'
      }) }
      it { is_expected.to contain_class('omd::node::export').that_requires('omd::node::config') }

      # further cannot be tested easily...
    end

    context "with parameter export => true, site => undef" do
      let(:params) { default_params.merge({
        :export => true,
      }) }
      it { is_expected.to raise_error(/does not match/) }
    end
    context "with parameter export => breakme, site => undef" do
      let(:params) { default_params.merge({
        :export => 'breakme',
      }) }
      it { is_expected.to raise_error(/is not a boolean/) }
    end
    context "with parameter export => true, site => break me" do
      let(:params) { default_params.merge({
        :export => true,
        :site   => 'break me',
      }) }
      it { is_expected.to raise_error(/does not match/) }
    end
    context "with parameter export => true, site => default, folder => break me" do
      let(:params) { default_params.merge({
        :export => true,
        :site   => 'default',
        :folder => 'break me',
      }) }
      it { is_expected.to raise_error(/does not match/) }
    end

  end


end
