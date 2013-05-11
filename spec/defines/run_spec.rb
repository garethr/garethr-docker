require 'spec_helper'

describe 'docker::run', :type => :define do
  let(:title) { 'sample' }

  context 'passing the required params' do
    let(:params) { {'command' => 'command', 'image' => 'base'} }
    it { should contain_file('/etc/init/docker-sample.conf').with_content(/docker run -m 0 base command/) }
    it { should contain_service('docker-sample') }
  end

  context 'when stopping the service' do
    let(:params) { {'command' => 'command', 'image' => 'base', 'running' => false} }
    it { should contain_service('docker-sample').with_ensure(false) }
  end

  context 'when passing a memory limit in bytes' do
    let(:params) { {'command' => 'command', 'image' => 'base', 'memory_limit' => '1000'} }
    it { should contain_file('/etc/init/docker-sample.conf').with_content(/-m 1000/) }
  end

  context 'when passing a port number' do
    let(:params) { {'command' => 'command', 'image' => 'base', 'port' => '4444'} }
    it { should contain_file('/etc/init/docker-sample.conf').with_content(/-p 4444/) }
  end

  context 'with an invalid title' do
    let(:title) { 'with spaces' }
    it do
      expect {
        should contain_service('docker-sample')
      }.to raise_error(Puppet::Error)
    end
  end

  context 'with an invalid image name' do
    let(:params) { {'command' => 'command', 'image' => 'with spaces', 'running' => 'not a boolean'} }
    it do
      expect {
        should contain_service('docker-sample')
      }.to raise_error(Puppet::Error)
    end
  end

  context 'with an invalid running value' do
    let(:title) { 'with spaces' }
    let(:params) { {'command' => 'command', 'image' => 'base', 'running' => 'not a boolean'} }
    it do
      expect {
        should contain_service('docker-sample')
      }.to raise_error(Puppet::Error)
    end
  end

  context 'with an invalid memory value' do
    let(:title) { 'with spaces' }
    let(:params) { {'command' => 'command', 'image' => 'base', 'memory' => 'not a number'} }
    it do
      expect {
        should contain_service('docker-sample')
      }.to raise_error(Puppet::Error)
    end
  end

end
