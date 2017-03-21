require 'spec_helper'

describe 'docker::compose', :type => :class do
  it { is_expected.to compile }

  let(:facts) { {
    :kernel                    => 'Linux',
    :osfamily                  => 'Debian',
    :operatingsystem           => 'Ubuntu',
    :lsbdistid                 => 'Ubuntu',
    :lsbdistcodename           => 'maverick',
    :kernelrelease             => '3.8.0-29-generic',
    :operatingsystemrelease    => '10.04',
    :operatingsystemmajrelease => '10',
  } }


  context 'when no proxy is provided' do
    let(:params) { {:version => '1.7.0'} }
    it { is_expected.to contain_exec('Install Docker Compose 1.7.0').with_command(
           'curl -s -L  https://github.com/docker/compose/releases/download/1.7.0/docker-compose-Linux-x86_64 > /usr/local/bin/docker-compose-1.7.0')
    }
  end

  context 'when proxy is provided' do
    let(:params) { {:proxy => 'http://proxy.example.org:3128/',
                    :version => '1.7.0'} }
    it { is_expected.to compile }
    it { is_expected.to contain_exec('Install Docker Compose 1.7.0').with_command(
           'curl -s -L --proxy http://proxy.example.org:3128/ https://github.com/docker/compose/releases/download/1.7.0/docker-compose-Linux-x86_64 > /usr/local/bin/docker-compose-1.7.0')
    }
  end

  context 'when proxy is not a http proxy' do
    let(:params)  { {:proxy => 'this is not a URL'} }
    it do
      expect {
        is_expected.to compile
      }.to raise_error(/does not match/)
    end
  end

  context 'when baseurl is provided' do
    let(:params) { {:baseurl => 'http://fetch.compose.from/here', :version => '1.7.0'} }
    it { is_expected.to contain_exec('Install Docker Compose 1.7.0').with_command(
           'curl -s -L  http://fetch.compose.from/here/1.7.0/docker-compose-Linux-x86_64 > /usr/local/bin/docker-compose-1.7.0')
    }
  end

  context 'when baseurl is not a url' do
    let(:params) { {:baseurl => 'this is not a URL'} }
    it do
      expect {
        is_expected.to compile
      }.to raise_error(/does not match/)
    end
  end

  context 'when rawurl is provided' do
    let(:params) { {:rawurl => 'http://fetch.compose.from/over-there', :version => '1.7.0'} }
    it { is_expected.to contain_exec('Install Docker Compose 1.7.0').with_command(
           'curl -s -L  http://fetch.compose.from/over-there > /usr/local/bin/docker-compose-1.7.0')
    }
  end

  context 'when rawurl is not a url' do
    let(:params) { {:rawurl => 'this is not a URL'} }
    it do
      expect {
        is_expected.to compile
      }.to raise_error(/does not match/)
    end
  end

end
