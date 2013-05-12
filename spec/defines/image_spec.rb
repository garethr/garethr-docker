require 'spec_helper'

describe 'docker::image', :type => :define do
  let(:title) { 'base' }
  it { should contain_exec('docker pull base') }

  context 'with ensure => absent' do
    let(:params) { { 'ensure' => 'absent' } }
    it { should contain_exec('docker rm base') }
  end

  context 'with ensure => absent' do
    let(:params) { { 'ensure' => 'present' } }
    it { should contain_exec('docker pull base') }
  end

  context 'with an invalid image name' do
    let(:title) { 'with spaces' }
    it do
      expect {
        should contain_exec('docker pull with spaces')
      }.to raise_error(Puppet::Error)
    end
  end

  context 'with an invalid ensure value' do
    let(:params) { { 'ensure' => 'not present or absent' } }
    it do
      expect {
        should contain_exec('docker rm base')
      }.to raise_error(Puppet::Error)
    end
  end

end
