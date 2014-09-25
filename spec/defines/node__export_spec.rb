require 'spec_helper'

describe 'omd::node::export' do
  let(:params) {{ :folder => 'collected_nodes' }}

  site_path = '/opt/omd/sites'
  wato_path = '/etc/check_mk/conf.d/wato'

  [ { :site   => 'default',
      :folder => 'collected_nodes',
      :fqdn   => 'foo.example.com' },
    { :site   => 'othersite',
      :folder => 'NODES',
      :fqdn   => 'bar.example.com' },
  ].each do |param|
    context "with values #{param.values.join(', ')}" do
      let(:title) { "#{param[:site]} - #{param[:fqdn]}" }
      let(:params) {{ :folder => param[:folder] }}

      hosts_file = "#{site_path}/#{param[:site]}#{wato_path}/#{param[:folder]}/hosts.mk"

      it do
        is_expected.to contain_concat__fragment("#{param[:site]} site's #{param[:folder]}/hosts.mk entry for #{param[:fqdn]}").with({
          :target  => hosts_file,
          :content => "  \"#{param[:fqdn]}|puppet_generated\",\n",
          :order   => 10,
        })
      end

      it do
        is_expected.to contain_exec("check_mk inventorize #{param[:fqdn]} for site #{param[:site]}").with({
          :command     => "su - #{param[:site]} -c 'check_mk -I #{param[:fqdn]}'",
          :refreshonly => true
        })
# not testable, since only in catlogue of collecting node
        #.that_subscribes_to("Concat:[#{hosts_file}]")
        #.that_comes_before("Exec[check_mk update site #{param[:site]}")
      end

    end
  end

# break me's
  context 'with broken title: \'break site\' - foo.example.com' do
    let(:title) { 'break site - foo.example.com' }
    it { is_expected.to raise_error(/does not match/) }
  end
  context 'with broken title: default - broken .example.com' do
    let(:title) { 'default - broken_example.com' }
    it { is_expected.to raise_error(/does not match/) }
  end
  context 'with broken parameter folder => break me' do
    let(:title) { 'default - foo.example.com' }
    let(:params) {{ :folder => 'break me' }}
    it { is_expected.to raise_error(/does not match/) }
  end

end
