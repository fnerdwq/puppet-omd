require 'spec_helper'

describe 'omd::site' do
  let(:title) { 'default' }

  # mock function from puppetdbquery
  # users rspec-puppet-utils MockFunction
  let!(:query_nodes) { 
    MockFunction.new('query_nodes') { |f|
      f.stubs(:call).returns([1,2,3,4])
    }
  }

  it { is_expected.to contain_omd__site('default') }
  it { is_expected.to contain_class('omd::server').that_comes_before('Omd::Site[default]') }

  context 'with title => break me' do
    let(:title) { 'break me' }
    it { is_expected.to raise_error(/does not match/) }
  end

  describe 'site creation' do
    it do
      is_expected.to contain_exec('create omd site: default').with({
        :command  => 'omd create default',
        :unless   => 'omd sites -b | grep -q \'\\<default\\>\'',
        :path     => ['/bin', '/usr/bin'],
      })
    end

    context 'for \'othersite\' with parameter ensure => absent' do
      let(:title)  { 'othersite' }
      let(:params) {{
        :ensure => 'absent',
      }}
      it do
        is_expected.to contain_exec('remove omd site: othersite').with({
          :command  => 'yes yes | omd rm --kill othersite',
          :onlyif   => 'omd sites -b | grep -q \'\\<othersite\\>\'',
        })
      end
    end
    context 'with parameter ensure => breakme' do
      let(:params) {{ :ensure => 'breakme' }}
      it { is_expected.to raise_error(/does not match/) }
    end

    context 'with parameter uid => 678' do
      let(:params) {{ :uid => 678 }}
      it { is_expected.to contain_exec('create omd site: default').with_command(
             'omd create --uid 678 default')
      }
    end
    context 'with parameter uid => breakme' do
      let(:params) {{ :uid => 'breakme' }}
      it { is_expected.to raise_error(/does not match/) }
    end

    context 'with parameter gid => 789' do
      let(:params) {{ :gid => 789 }}
      it { is_expected.to contain_exec('create omd site: default').with_command(
             'omd create --gid 789 default')
      }
    end
    context 'with parameter gid => breakme' do
      let(:params) {{ :uid => 'breakme' }}
      it { is_expected.to raise_error(/does not match/) }
    end
  end

  describe 'site configuration' do
    let(:params) {{ :options => { 'DEFAULT_GUI' => 'check_mk' } }}
    it do
      is_expected.to contain_omd__site__config('default').with_options(
        { 'DEFAULT_GUI' => 'check_mk' })\
      .that_requires('Exec[create omd site: default]')\
      .that_notifies('Omd::Site::Service[default]')
    end
  end

  describe 'site service' do
    it do
      is_expected.to contain_omd__site__service('default').with({
        :ensure => 'running',
        :reload => false,
      }).that_subscribes_to('Exec[create omd site: default]')
    end
    context 'for \'othersite\' with parameters { service_ensure => stopped, service_reload => true }' do
      let(:title) { 'othersite' }
      let(:params) {{
        :service_ensure => 'stopped',
        :service_reload => true,
      }}
      it do
        is_expected.to contain_omd__site__service('othersite').with({
          :ensure => 'stopped',
          :reload => true,
        }).that_subscribes_to('Exec[create omd site: othersite]')
      end
    end
  end

  describe 'client configuration' do
    it do
      is_expected.to contain_omd__site__config_clients('default').with({
        :folder => 'collected_clients',
      }).that_requires( 'Omd::Site::Service[default]')
    end

    context 'with parameter config_clients => false' do
      let(:params) {{ :config_clients => false }}
      it { is_expected.to_not contain_omd__site__config_clients('default') }
    end
    context 'with parameter config_clients => breakme' do
      let(:params) {{ :config_clients => 'breakme' }}
      it { is_expected.to raise_error(/is not a boolean/) }
    end

    context 'with parameter config_clients_folder => otherfolder' do
      let(:params) {{ :config_clients_folder => 'otherfolder' }}
      it do
        is_expected.to contain_omd__site__config_clients('default').with({
          :folder => 'otherfolder',
        })
      end
    end


  end


end
