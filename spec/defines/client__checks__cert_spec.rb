require 'spec_helper'

describe 'omd::client::checks::cert' do
  let(:title) { '/etc/ssl/certs/ssl-cert-snakeoil.pem' }

  # we need to set the must parameter
  let(:pre_condition) { 'class omd::client { $check_mk_version = "1.2.3" }' }

  it { is_expected.to contain_class('omd::client::checks') }

  it do
    is_expected.to contain_concat__fragment('check_cert__etc_ssl_certs_ssl-cert-snakeoil.pem').with({
      :target  => '/etc/check_mk/mrpe.cfg',
      :content => "Cert__etc_ssl_certs_ssl-cert-snakeoil.pem\t/usr/local/lib/nagios/plugins/check_cert.rb -w 2592000 -c 604800 --cert /etc/ssl/certs/ssl-cert-snakeoil.pem \n",
      :order   => '50',
    }).that_requires('File[check_cert]')
  end

  context 'with title => A Cert.pem and parameter path => /path/to/ACert.pem' do
    let(:title) { 'A Cert.pem' }
    let(:params) {{ :path => '/path/to/ACert.pem' }}

    it do
      is_expected.to contain_concat__fragment('check_cert_A_Cert.pem').with_content(
        "Cert_A_Cert.pem\t/usr/local/lib/nagios/plugins/check_cert.rb -w 2592000 -c 604800 --cert /path/to/ACert.pem \n")
    end
  end
  context 'parameter path => break me' do
    let(:params) {{ :path => 'break me' }}
    it { is_expected.to raise_error(/is not an absolute path/) }
  end

  context 'with parameter warn => 14400' do
    let(:params) {{ :warn => 14400 }}
      it { is_expected.to contain_concat__fragment('check_cert__etc_ssl_certs_ssl-cert-snakeoil.pem').with_content(/-w 14400/)
    }
  end
  context 'with parameter warn => breakme' do
    let(:params) {{ :warn => 'breakme' }}
      it { is_expected.to raise_error(/does not match/)
    }
  end

  context 'with parameter crit => 14400' do
    let(:params) {{ :crit => 14400 }}
      it { is_expected.to contain_concat__fragment('check_cert__etc_ssl_certs_ssl-cert-snakeoil.pem').with_content(/-c 14400/)
    }
  end
  context 'with parameter crit => breakme' do
    let(:params) {{ :crit => 'breakme' }}
      it { is_expected.to raise_error(/does not match/)
    }
  end

  context 'with parameter options => \'-f -e\'' do
    let(:params) {{ :options => '-f -e'}}
      it { is_expected.to contain_concat__fragment('check_cert__etc_ssl_certs_ssl-cert-snakeoil.pem').with_content(/-f -e/)
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
