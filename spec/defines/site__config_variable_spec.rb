require 'spec_helper'

describe 'omd::site::config_variable' do
  let(:title) { 'default - DEFAULT_GUI = welcome' }

  it { is_expected.to contain_omd__site__config_variable('default - DEFAULT_GUI = welcome') }

  it do
    is_expected.to contain_exec('config omd site: default - DEFAULT_GUI = welcome').with({
      :command => 'omd stop default; omd config default set DEFAULT_GUI welcome',
      :unless  => 'omd config default show DEFAULT_GUI | grep -q \'^welcome$\'',
      :path    => ['/bin', '/usr/bin'],
    })
  end

  context 'for another site \'othersite\'' do
    let(:title) { 'othersite - DEFAULT_GUI = welcome' }
    it do
      is_expected.to contain_exec('config omd site: othersite - DEFAULT_GUI = welcome').with({
        :command => 'omd stop othersite; omd config othersite set DEFAULT_GUI welcome',
        :unless  => 'omd config othersite show DEFAULT_GUI | grep -q \'^welcome$\'',
      })
    end
  end

  context 'for another value \'check_mk\'' do
    let(:title) { 'default - DEFAULT_GUI = check_mk' }
    it do
      is_expected.to contain_exec('config omd site: default - DEFAULT_GUI = check_mk').with({
        :command => 'omd stop default; omd config default set DEFAULT_GUI check_mk',
        :unless  => 'omd config default show DEFAULT_GUI | grep -q \'^check_mk$\'',
      })
    end
  end

  context 'for another variable/value \'CRONTAB/off\'' do
    let(:title) { 'default - CRONTAB = off' }
    it do
      is_expected.to contain_exec('config omd site: default - CRONTAB = off').with({
        :command => 'omd stop default; omd config default set CRONTAB off',
        :unless  => 'omd config default show CRONTAB | grep -q \'^off$\'',
      })
    end
  end

  ['APACHE_MODE', 'APACHE_TCP_ADDR', 'APACHE_TCP_PORT', 'AUTOSTART', 'CORE', 'CRONTAB', 'DEFAULT_GUI',
   'DOKUWIKI_AUTH', 'LIVESTATUS_TCP', 'MKEVENTD', 'MOD_GEARMAN', 'MONGODB', 'MULTISITE_AUTHORISATION',
   'MULTISITE_COOKIE_AUTH', 'MYSQL', 'NAGIOS_THEME', 'NAGVIS_URLS', 'NSCA', 'PNP4NAGIOS',
   'THRUK_COOKIE_AUTH', 'TMPFS'
  ].each do |var|
    context "allow variables #{var}" do
      let(:title) { "default - #{var} = something" }
      it do
        is_expected.to contain_exec("config omd site: default - #{var} = something").with_command(/#{var}/)
      end
    end
  end

  context 'broken variable BREAKME' do
    let(:title) { "default - BREAKME = something" }
    it { is_expected.to raise_error(/Option BREAKME not in list of allowed options!/) }
  end

end
