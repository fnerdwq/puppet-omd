require 'spec_helper'

describe 'omd::client::checks::puppet' do

  # we need to set the must parameter
  let(:pre_condition) { 'class omd::client { $check_mk_version = "1.2.3" }' }

  it { is_expected.to contain_class('omd::client::checks') }

  it do
    is_expected.to contain_concat__fragment('check_puppet').with({
      :target  => '/etc/check_mk/mrpe.cfg',
      :content => "Puppet_Agent\t/usr/local/lib/nagios/plugins/check_puppet.rb -w 3600 -c 7200 \n",
      :order   => '50',
    }).that_requires('File[check_puppet]')
  end

  context 'with parameter warn => 14400' do
    let(:params) {{ :warn => 14400 }}
      it { is_expected.to contain_concat__fragment('check_puppet').with_content(/-w 14400/)
    }
  end
    context 'with parameter warn => breakme' do
    let(:params) {{ :warn => 'breakme' }}
      it { is_expected.to raise_error(/does not match/)
    }
  end

  context 'with parameter crit => 14400' do
    let(:params) {{ :crit => 14400 }}
      it { is_expected.to contain_concat__fragment('check_puppet').with_content(/-c 14400/)
    }
  end
    context 'with parameter crit => breakme' do
    let(:params) {{ :crit => 'breakme' }}
      it { is_expected.to raise_error(/does not match/)
    }
  end

  context 'with parameter options => \'-f -e\'' do
    let(:params) {{ :options => '-f -e'}}
      it { is_expected.to contain_concat__fragment('check_puppet').with_content(/-f -e/)
    }
  end
    context 'with parameter options => {}' do
    let(:params) {{ :options => {} }}
      it { is_expected.to raise_error(/is not a string/)
    }
  end

  describe 'reinventorize trigger export' do
    # not testable for the moment
  end
end
