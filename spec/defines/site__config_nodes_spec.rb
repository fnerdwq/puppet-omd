require 'spec_helper'

describe 'omd::site::config_nodes' do
  let(:title) { 'default' }
  let(:default_params) {{
    :folder => 'a_default'
  }}
  let(:params) { default_params }

  # mock function from puppetdbquery
  # users rspec-puppet-utils MockFunction
  let!(:query_nodes) { 
    MockFunction.new('query_nodes') { |f|
      f.stubs(:call).returns([1,2,3,4])
    }
  }

  it { is_expected.to contain_omd__site__config_nodes('default') }

  site_path = '/omd/sites'
  wato_path = '/etc/check_mk/conf.d/wato'
  ['collected_nodes', 'NODES'].each do |folder|
    context "with parameter folder => #{folder}" do
      let(:params) { default_params.merge({ :folder => folder }) }
      it do
        is_expected.to contain_file("#{site_path}/default#{wato_path}/#{folder}").with({
          :ensure => 'directory',
          :owner  => 'default',
          :group  => 'default',
          :mode   => '0770',
        })
      end
  
      it do
        is_expected.to contain_concat("#{site_path}/default#{wato_path}/#{folder}/hosts.mk").with({
          :ensure => 'present',
          :owner  => 'default',
          :group  => 'default',
          :mode   => '0660',
        })
      end
  
      it do 
        is_expected.to contain_concat__fragment("default site's #{folder}/hosts.mk header").with({
          :target  => "#{site_path}/default#{wato_path}/#{folder}/hosts.mk",
          :order   => '01',
          :content => /_lock='Puppet generated'\n\nall_hosts \+= \[/,
        })
      end
      it do 
        is_expected.to contain_concat__fragment("default site\'s #{folder}/hosts.mk footer").with({
          :target  => "#{site_path}/default#{wato_path}/#{folder}/hosts.mk",
          :order   => '99',
          :content => /\]/,
        })
      end

      it do
        is_expected.to contain_file("default site\'s #{folder}/.wato file").with({
          :ensure  => 'present',
          :path    => "#{site_path}/default#{wato_path}/#{folder}/.wato",
          :content => /'title':.*#{folder}/,
          :owner   => 'default',
          :group   => 'default',
          :mode    => '0660',
        })
      end

      it do
        is_expected.to contain_exec("check_mk update site default").with({
          :command     => "su - default -c 'check_mk -O'",
          :refreshonly => true,
        }).that_subscribes_to("Concat[#{site_path}/default#{wato_path}/#{folder}/hosts.mk]")
      end

    end
  end

  context 'with parmeter folder => break me' do
    let(:params) { default_params.merge({ :folder => 'break me' }) }
    it { is_expected.to raise_error(/does not match/) }
  end

end
