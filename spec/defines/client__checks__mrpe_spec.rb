require 'spec_helper'

describe 'omd::client::checks::mrpe' do
  let(:title) { 'Test_Check' }
  let(:params) {{ :path => '/usr/local/lib/nagios/plugins/test_check.sh' }}

  # we need to set the must parameter
  let(:pre_condition) { 'class omd::client { $check_mk_version = "1.2.3" }' }

  it { is_expected.to contain_class('omd::client::checks') }

  it do
    is_expected.to contain_concat__fragment('check_mrpe_Test_Check').with({
      :target  => '/etc/check_mk/mrpe.cfg',
      :content => "Test_Check\t/usr/local/lib/nagios/plugins/test_check.sh \n",
      :order   => '50',
    })
  end

  context 'with title => A_check, parameter path => /path/to/check.sh and options => -H ahost.localhost' do
    let(:title) { 'A_Check' }
    let(:params) {{ :path    => '/path/to/ACert.pem', :options => '-H ahost.localhost' }}

    it do
      is_expected.to contain_concat__fragment('check_mrpe_A_Check').with_content(
        "A_Check\t/path/to/ACert.pem -H ahost.localhost\n")
    end
  end
  context 'parameter path => break me' do
    let(:params) {{ :path => 'break me' }}
    it { is_expected.to raise_error(/is not an absolute path/) }
  end

  context 'with parameter options => {}' do
    let(:params) {{ :path => '/some/set/path', :options => {} }}
      it { is_expected.to raise_error(/is not a string/)
    }
  end

  describe 'reinventorize trigger export' do
    # not testable for the moment
  end
end
