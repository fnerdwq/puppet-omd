require 'spec_helper'

describe 'omd::client::checks::logwatch' do
  let(:title) { 'some_logfile' }
  let(:params) {{ :content => "/path/to/log\n C crit" }}

  # we need to set the must parameter
  let(:pre_condition) {[
    'class omd::client { $check_mk_version = "1.2.3" }',
    'class omd::client { $logwatch_install = true }',
    'class omd::client { $user = "check_user" }',
    'class omd::client { $group = "check_group" }',
  ]}

  it { is_expected.to contain_class('omd::client::checks') }

  it do
    is_expected.to contain_file('/etc/check_mk/logwatch.d/some_logfile.cfg').with({
      :content => "/path/to/log\n C crit",
      :owner   => 'check_user',
      :group   => 'check_group',
    })
  end

  context 'parameter title => break me' do
    let(:title) {{ :path => 'break me' }}
    it { is_expected.to raise_error(/does not match/) }
  end

  describe 'reinventorize trigger export' do
    # not testable for the moment
  end
end
