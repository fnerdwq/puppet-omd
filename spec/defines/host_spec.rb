require 'spec_helper'

describe 'omd::host' do
  let(:title) { 'default' }
  let(:default_params) {{
    :folder => 'collected_hosts',
    :tags   => ['some_tag']
  }}
  let(:params) { default_params }

  # we need to set the must parameter
  let(:pre_condition) { 'class omd::client { $check_mk_version = "1.2.3" }' }

  it { is_expected.to contain_class('omd::client') }

  # external resource cannot be tested...

  describe 'with broken site name (title) => break me' do
    let(:title) { 'break me' }
    it { is_expected.to raise_error(/does not match/) }
  end

end
