require 'spec_helper'

describe 'docker::compose', :type => :class do
  it { is_expected.to compile }

  let(:facts) { {:kernel => 'Linux'} }


  context 'when no install_url is provided' do
    let(:params) { {:version => '1.5.2'} }
    it { is_expected.to contain_class('docker::compose').with_install_url(
           'https://github.com/docker/compose/releases/download/1.5.2/docker-compose-Linux-x86_64') }
    it { is_expected.to contain_exec('Install Docker Compose 1.5.2').with_command('curl -s -L https://github.com/docker/compose/releases/download/1.5.2/docker-compose-Linux-x86_64 > /usr/local/bin/docker-compose-1.5.2') }
  end

  context 'when a new install_url is provided' do
    let(:params) { {:install_url => 'http://example.com/docker/compose/download/file',
                   :version => '1.5.2'} }
    it { is_expected.to compile }
    it { is_expected.to contain_class('docker::compose').with_install_url(
           'http://example.com/docker/compose/download/file')
    }
    it { is_expected.to contain_exec('Install Docker Compose 1.5.2').with_command('curl -s -L http://example.com/docker/compose/download/file > /usr/local/bin/docker-compose-1.5.2') }
  end

  context 'when install_url is not a url' do
    let(:params)  { {:install_url => 'this is not a URL'} }
    it do
      expect {
        is_expected.to compile
      }.to raise_error(/does not match/)
    end
  end

end
