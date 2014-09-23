require 'spec_helper'

describe 'omd::site' do
  let(:title) { 'default' }

  it { is_expected.to contain_omd__site('default') }
  it { is_expected.to contain_class('omd') }

  # Site creation
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

  ### Site configuration
  # TODO

  ### Site service
  it do
    is_expected.to contain_omd__site__service('default').with({
      :ensure => 'running',
      :reload => false,
    }).that_requires('Exec[create omd site: default]')
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
      }).that_requires('Exec[create omd site: othersite]')
    end
  end


end
