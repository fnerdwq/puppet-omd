require 'spec_helper'

describe 'omd::site::service' do
  let(:title) { 'default' }
  let(:default_params) {{
    :ensure => 'running',
    :reload => false,
  }}
  let(:params) { default_params }

  it { is_expected.to contain_omd__site__service('default') }

# TODO enable => _true/ false  - omd enable/disable
  it do
    is_expected.to contain_exec('start omd site: default').with({
      :command => 'omd start default',
      :unless  => 'omd status -b default',
      :returns => [0,2],
      :path    => ['/bin', '/usr/bin'],
    })
  end

  it do
    is_expected.to contain_exec('restart omd site: default').with({
      :command     => 'omd restart default',
      :onlyif      => 'omd status -b default',
      :refreshonly => true,
      :path        => ['/bin', '/usr/bin'],
    })
  end

  context 'parameter ensure => stopped' do
    let(:params) { default_params.merge({ :ensure => 'stopped' }) }
    it do
      is_expected.to contain_exec('stop omd site: default').with({
        :command => 'omd stop default',
        :onlyif  => 'omd status -b default',
        :returns => [0,2],
      })
    end
    it { is_expected.to_not contain_exec('restart omd site: default') }
  end
  context 'parameter ensure => breakme' do
    let(:params) { default_params.merge({ :ensure => 'breakme' }) }
    it { is_expected.to raise_error(/does not match/) }
  end

  context 'parameter reload => true' do
    let(:params) { default_params.merge({ :reload => true }) }
    it do
      is_expected.to contain_exec('reload omd site: default').with_command('omd reload default')
    end
  end
  context 'parameter reload => breakme' do
    let(:params) { default_params.merge({ :reload => 'breakme' } )}
    it { is_expected.to raise_error(/is not a boolean/) }
  end


end
