require 'spec_helper'

describe 'omd::server' do

  # mock function from puppetdbquery
  # users rspec-puppet-utils MockFunction
  let!(:query_nodes) {
    MockFunction.new('query_nodes') { |f|
      f.stubs(:call).returns([1,2,3,4])
    }
  }

  let(:facts) {{ :puppet_vardir => '/var/lib/puppet' }}

  it { is_expected.to contain_class('omd::server::params') }
  it { is_expected.to contain_class('omd::server::install') }
  it { is_expected.to contain_class('omd::server::config').that_requires('Class[omd::server::install]') }

  describe 'installation' do

    context 'on RedHat like systems' do
      facts = {
          :osfamily        => 'RedHat',
          :operatingsystem => 'CentOS',
      }
      let(:facts) { facts.merge({ :operatingsystemmajrelease => '6', }) }

      it { is_expected.to contain_class('omd::server::install::redhat').that_comes_before('Package[omd]') }
      it { is_expected.to contain_class('epel') }

      it do
        is_expected.to contain_package('omd-repository').with({
          :name     => 'labs-consol-stable',
          :source   => 'https://labs.consol.de/repo/stable/rhel6/i386/labs-consol-stable.rhel6.noarch.rpm',
          :provider => 'rpm',
        })
      end

      context 'on RHEL7' do
        let(:facts) { facts.merge({ :operatingsystemmajrelease => '7', }) }
        it do
          is_expected.to contain_package('omd-repository').with({
            :name     => 'labs-consol-stable',
            :source   => 'https://labs.consol.de/repo/stable/rhel7/i386/labs-consol-stable.rhel7.noarch.rpm',
            :provider => 'rpm',
          })
        end
      end

      context 'with parameter repo => testing' do
        let(:params) {{ :repo => 'testing' }}

        it do
          is_expected.to contain_package('omd-repository').with({
            :name   => 'labs-consol-testing',
            :source => /labs\.consol\.de\/repo\/testing\/.*labs-consol-testing/,
          })
        end
        it { is_expected.to contain_package('omd').with_name('omd').with_allow_virtual('true') }
      end

    end

    context 'on Debian like systems' do
      it { is_expected.to contain_class('omd::server::install::debian').that_comes_before('Package[omd]') }
      it { is_expected.to contain_class('apt') }

      context 'on Debian' do
        it { is_expected.to contain_apt__source('omd').with({
            :location    => 'http://labs.consol.de/repo/stable/debian',
            :release     => 'wheezy',
            :repos       => 'main',
            :key         => { :id => 'F2F97737B59ACCC92C23F8C7F8C1CA08A57B9ED7',
                              :content => /mI0EThw4TQEEA/
                            },
          })
        }
      end

      context 'on Ubuntu' do
        let(:facts) {{
          :operatingsystem => 'Ubuntu',
          :lsbdistid       => 'Ubuntu',
          :lsbdistcodename => 'trusty',
        }}
        it { is_expected.to contain_apt__source('omd').with({
            :location    => 'http://labs.consol.de/repo/stable/ubuntu',
            :release     => 'trusty',
            :repos       => 'main',
            :key         => { :id => 'F2F97737B59ACCC92C23F8C7F8C1CA08A57B9ED7',
                              :content => /mI0EThw4TQEEA/,
                            },
          })
        }
      end

      context 'with parameter repo => testing' do
        let(:params) {{ :repo => 'testing' }}
        it do
          is_expected.to contain_apt__source('omd').with_location(/labs\.consol\.de\/repo\/testing\//)
        end
        it { is_expected.to contain_package('omd').with_name('omd-daily') }
      end

    end

    it { is_expected.to contain_package('omd').with_ensure('installed') }
    ['latest','absent','purged'].each { |ver|
      context "with parameter ensure => #{ver}" do
        let(:params) {{ :ensure => ver }}
        it { is_expected.to contain_package('omd').with_ensure(ver).with_name('omd') }
      end
    }
    context 'with parameter ensure => 1.20' do
      let(:params) {{ :ensure => '1.20' }}
      it { is_expected.to contain_package('omd').with_ensure('present').with_name("omd-1.20") }
    end
    context 'with parameter ensure => breakme' do
      let(:params) {{ :ensure => 'breakme' }}
      it { is_expected.to raise_error(/does not match/) }
    end

    context 'with parameter testing => testing' do
      let(:params) {{ :repo => 'breakme' }}
      it { is_expected.to raise_error(/does not match/) }
    end

    context 'with parameter configure_repo => false' do
      let(:params) {{ :configure_repo => false }}
      it { is_expected.not_to contain_apt__source('omd') }
      it { is_expected.not_to contain_package('omd-repository') }
    end
    context 'with parameter configure_repo => breakme' do
      let(:params) {{ :configure_repo => 'breakme' }}
      it { is_expected.to raise_error(/is not a boolean/) }
    end
  end

  describe 'configuration' do
    it do
      is_expected.to contain_file('/var/lib/puppet/omd').with({
        :ensure => 'directory',
        :owner  => 'root',
        :group  => 'root',
        :mode   => '0755',
      })
    end
  end

  describe 'site creation' do
    it { is_expected.to contain_omd__site('default') }

    context 'with paramter sites => breakme' do
      let(:params) {{ :sites => 'breakme' }}
      it { is_expected.to raise_error(/is not a Hash/) }
    end

    context 'with parameter sites => { othersite => { uid => 678 }, site2 => {} }' do
      let(:params) {{
        :sites => {
          'othersite' => { 'uid' => 678 },
          'site2'     => {}
        }
      }}
      it do
        is_expected.to contain_omd__site('othersite').with_uid(678)
      end
      it do
        is_expected.to contain_omd__site('site2')
      end
    end
    context 'with parameter sites_defaults => { uid => 678, gid => 876 }' do
      let(:params) {{
        :sites_defaults => {
          'uid' => 678,
          'gid' => 876
        },
      }}
      it { is_expected.to contain_omd__site('default').with_uid(678).with_gid(876) }
    end

  end


end
