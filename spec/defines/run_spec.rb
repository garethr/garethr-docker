require 'spec_helper'

describe 'docker::run', :type => :define do
  let(:title) { 'sample' }
  let(:params) { {'command' => 'command', 'image' => 'base'} }

  it { should contain_file('/etc/init/docker-sample.conf').with_content(/docker run -d base command/) }
  it { should contain_service('docker-sample') }

  context 'when stopping the service' do
    let(:params) { {'command' => 'command', 'image' => 'base', 'running' => false} }
    it { should contain_service('docker-sample').with_ensure(false) }
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


end
