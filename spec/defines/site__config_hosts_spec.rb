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
    :site   => 'othersite',
    :folder => 'NODES'
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
        is_expected.to contain_concat__fragment("#{site} site's #{folder}/hosts.mk all_hosts begin").with({
          :target  => "#{site_path}/#{site}#{wato_path}/#{folder}/hosts.mk",
          :order   => '01',
          :content => /_lock='Puppet generated'\n\nall_hosts \+= \[/,
        })
      end
      it do
        is_expected.to contain_concat__fragment("#{site} site\'s #{folder}/hosts.mk all_hosts end").with({
          :target  => "#{site_path}/#{site}#{wato_path}/#{folder}/hosts.mk",
          :order   => '09',
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

      it do
        is_expected.to contain_concat__fragment("#{site} site's #{folder}/hosts.mk COMMENT OUT clusters begin").with({
          :target  => "#{site_path}/#{site}#{wato_path}/#{folder}/hosts.mk",
          :order   => '10',
          :content => "'''\n",
        })
      end
      it do
        is_expected.to contain_concat__fragment("#{site} site's #{folder}/hosts.mk COMMENT OUT clusters end").with({
          :target  => "#{site_path}/#{site}#{wato_path}/#{folder}/hosts.mk",
          :order   => '19',
          :content => "'''\n",
        })
      end

    end
  end

  context 'with parameter folder => break me' do
    let(:title) { 'default - break me' }
    it { is_expected.to raise_error(/does not match/) }
  end

  context 'with parameter cluster => true, cluster_tags => [tag1, tag2]' do
    let(:title) { 'default - folder' }
    let(:params) {{ :cluster => true, :cluster_tags => ['tag1','tag2'] }}
    it do
      is_expected.to contain_concat__fragment("default site's folder/hosts.mk clusters begin").with({
        :target  => '/omd/sites/default/etc/check_mk/conf.d/wato/folder/hosts.mk',
        :order   => '11',
        :content => "clusters\.update({\n\"folder\|puppet_generated\|cluster\|tag1\|tag2\": [\n",
      })
    end
    it do
      is_expected.to contain_concat__fragment("default site's folder/hosts.mk clusters end").with({
        :target  => '/omd/sites/default/etc/check_mk/conf.d/wato/folder/hosts.mk',
        :order   => '18',
        :content => "] })\n",
      })
    end

    it { is_expected.to_not contain_concat__fragment("default site's folder/hosts.mk COMMENT OUT clusters begin") }
    it { is_expected.to_not contain_concat__fragment("default site's folder/hosts.mk COMMENT OUT clusters end") }

  end

  context 'with parameter cluster => break me' do
    let(:title) { 'default - folder' }
    let(:params) {{ :cluster => 'break me' }}
    it { is_expected.to raise_error(/is not a boolean/) }
  end
  context 'with parameter cluster => true, cluster_tags => breakme' do
    let(:title) { 'default - folder' }
    let(:params) {{ :cluster => true, :cluster_tags => 'break me' }}
    it { is_expected.to raise_error(/is not an Array/) }
  end

  describe 'node collection' do
    #exported resources not testable
  end

end
