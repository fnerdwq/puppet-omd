require 'spec_helper'

describe 'omd::site::config_hosts' do
  let(:title) { 'default - a_default' }

  # mock function from puppetdbquery
  # users rspec-puppet-utils MockFunction
  let!(:query_nodes) { 
    MockFunction.new('query_nodes') { |f|
      f.stubs(:call).returns([1,2,3,4])
    }
  }

  it { is_expected.to contain_omd__site__config_hosts('default - a_default') }

  site_path = '/omd/sites'
  wato_path = '/etc/check_mk/conf.d/wato'
  [{
    :site   => 'default',
    :folder => 'collected_hosts'
   },
   { 
    :site  => 'othersite',
    :folder=> 'NODES'
   }
  ].each do |param|
    site   = param[:site]
    folder = param[:folder]

    context "with title \'#{site} - #{folder}\'" do
      let(:title) { "#{site} - #{folder}" }
      it do
        is_expected.to contain_file("#{site_path}/#{site}#{wato_path}/#{folder}").with({
          :ensure => 'directory',
          :owner  => site,
          :group  => site,
          :mode   => '0770',
        })
      end
  
      it do
        is_expected.to contain_concat("#{site_path}/#{site}#{wato_path}/#{folder}/hosts.mk").with({
          :ensure => 'present',
          :owner  => site,
          :group  => site,
          :mode   => '0660',
        })
      end
  
      it do 
        is_expected.to contain_concat__fragment("#{site} site's #{folder}/hosts.mk header").with({
          :target  => "#{site_path}/#{site}#{wato_path}/#{folder}/hosts.mk",
          :order   => '01',
          :content => /_lock='Puppet generated'\n\nall_hosts \+= \[/,
        })
      end
      it do 
        is_expected.to contain_concat__fragment("#{site} site\'s #{folder}/hosts.mk footer").with({
          :target  => "#{site_path}/#{site}#{wato_path}/#{folder}/hosts.mk",
          :order   => '99',
          :content => /\]/,
        })
      end

      it do
        is_expected.to contain_file("#{site} site\'s #{folder}/.wato file").with({
          :ensure  => 'present',
          :path    => "#{site_path}/#{site}#{wato_path}/#{folder}/.wato",
          :content => /'title':.*#{folder}/,
          :owner   => site,
          :group   => site,
          :mode    => '0660',
        })
      end

    end
  end

  context 'with parameter folder => break me' do
    let(:title) { 'default - break me' }
    it { is_expected.to raise_error(/does not match/) }
  end

  describe 'node collection' do
    # exported resources not testable
  end

end
