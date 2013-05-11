require 'spec_helper'

describe 'docker::pull', :type => :define do
  let(:title) { 'base' }
  it { should contain_exec('docker pull base').with_timeout(0) }

 context 'with an invalid image name' do
    let(:title) { 'with spaces' }
    it do
      expect {
        should contain_exec('docker pull with spaces')
      }.to raise_error(Puppet::Error)
    end
  end

end
