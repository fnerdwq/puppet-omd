require 'spec_helper'

describe 'omd::site' do
    let(:title) { 'default' }

    it { is_expected.to contain_omd__site('default') }

    it { is_expected.to contain_class('omd') }

    it do
      is_expected.to contain_exec('create omd site: default').with({
        :command  => 'omd create default',
        :unless   => 'omd sites -b | grep -q \'\\<default\\>\'',
        :path     => ['/bin', '/usr/bin'],
      })
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

    it do
      is_expected.to contain_omd__service('default').with({ })
    end


end
