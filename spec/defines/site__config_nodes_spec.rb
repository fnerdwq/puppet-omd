require 'spec_helper'

describe 'omd::site::config_nodes' do
  let(:title) { 'default' }
  let(:default_params) {{
    :folder => 'a_default'
  }}
  let(:params) { default_params }

  it { is_expected.to contain_omd__site__config_nodes('default') }

  site_path = '/opt/omd/sites'
  wato_path = '/etc/check_mk/conf.d/wato'
  ['collected_nodes', 'NODES'].each do |nodes_dir|
    context "with parameter folder => #{nodes_dir}" do
      let(:params) { default_params.merge({ :folder => nodes_dir }) }
      it do
        is_expected.to contain_file("#{site_path}/default#{wato_path}/#{nodes_dir}").with({
          :ensure => 'directory',
          :owner  => 'default',
          :group  => 'default',
          :mode   => '0770',
        })
      end
  
      it do
        is_expected.to contain_concat("#{site_path}/default#{wato_path}/#{nodes_dir}/hosts.mk").with({
          :ensure => 'present',
          :owner  => 'default',
          :group  => 'default',
          :mode   => '0660',
        })
      end
  
      it do 
        is_expected.to contain_concat__fragment('default site\'s hosts.mk header').with({
          :target  => "#{site_path}/default#{wato_path}/#{nodes_dir}/hosts.mk",
          :order   => '01',
          :content => /_lock='Puppet generated'\n\nall_hosts \+= \[/,
        })
      end
      it do 
        is_expected.to contain_concat__fragment('default site\'s hosts.mk footer').with({
          :target  => "#{site_path}/default#{wato_path}/#{nodes_dir}/hosts.mk",
          :order   => '99',
          :content => /\]/,
        })
      end

      it do
        is_expected.to contain_file("default site\'s #{nodes_dir}/.wato file").with({
          :ensure  => 'present',
          :path    => "#{site_path}/default#{wato_path}/#{nodes_dir}/.wato",
          :content => /'title':.*#{nodes_dir}/,
          :owner   => 'default',
          :group   => 'default',
          :mode    => '0660',
        })
      end

      it do
        is_expected.to contain_exec("check_mk update site default").with({
          :command     => "su - default -c 'check_mk -O'",
          :refreshonly => true,
        }).that_subscribes_to("Concat[#{site_path}/default#{wato_path}/#{nodes_dir}/hosts.mk]")
      end

    end
  end

  context 'with parmeter folder => break me' do
    let(:params) { default_params.merge({ :folder => 'break me' }) }
    it { is_expected.to raise_error(/does not match/) }
  end

end
