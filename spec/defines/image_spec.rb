require 'spec_helper'

describe 'docker::image', :type => :define do
  let(:title) { 'base' }
  it { should contain_exec('docker pull base') }

  context 'with ensure => absent' do
    let(:params) { { 'ensure' => 'absent' } }
    it { should contain_exec('docker rmi base') }
  end

  context 'with ensure => absent and force => true' do
    let(:params) { { 'ensure' => 'absent', 'force' => true } }
    it { should contain_exec('docker rmi -f base') }
  end

  context 'with ensure => absent and image_tag => precise' do
    let(:params) { { 'ensure' => 'absent', 'image_tag' => 'precise' } }
    it { should contain_exec('docker rmi base:precise') }
  end

  context 'with ensure => present' do
    let(:params) { { 'ensure' => 'present' } }
    it { should contain_exec('docker pull base') }
  end

  context 'with docker_file => Dockerfile' do
    let(:params) { { 'docker_file' => 'Dockerfile' }}
    it { should contain_exec('docker build -t base - < Dockerfile') }
  end


  context 'with ensure => present and docker_file => Dockerfile' do
    let(:params) { { 'ensure' => 'present', 'docker_file' => 'Dockerfile' } }
    it { should contain_exec('docker build -t base - < Dockerfile') }
  end

  context 'with docker_dir => /tmp/docker_images/test1' do
    let(:params) { { 'docker_dir' => '/tmp/docker_images/test1' }}
    it { should contain_exec('docker build -t base /tmp/docker_images/test1') }
  end

  context 'with ensure => present and docker_dir => /tmp/docker_images/test1' do
    let(:params) { { 'ensure' => 'present', 'docker_dir' => '/tmp/docker_images/test1' } }
    it { should contain_exec('docker build -t base /tmp/docker_images/test1') }
  end

  context 'with ensure => present and image_tag => precise' do
    let(:params) { { 'ensure' => 'present', 'image_tag' => 'precise' } }
    it { should contain_exec('docker pull base:precise') }
  end

  context 'with ensure => present and image_tag => precise and docker_file => Dockerfile' do
    let(:params) { { 'ensure' => 'present', 'image_tag' => 'precise', 'docker_file' => 'Dockerfile' } }
    it { should contain_exec('docker build -t base:precise - < Dockerfile') }
  end

  context 'with ensure => present and image_tag => precise and docker_dir => /tmp/docker_images/test1' do
    let(:params) { { 'ensure' => 'present', 'image_tag' => 'precise', 'docker_dir' => '/tmp/docker_images/test1' } }
    it { should contain_exec('docker build -t base:precise /tmp/docker_images/test1') }
  end

  context 'with docker_file => Dockerfile and docker_dir => /tmp/docker_images/test1' do
    let(:params) { { 'docker_file' => 'Dockerfile', 'docker_dir' => '/tmp/docker_images/test1' }}
    it do
      expect {
        should have_exec_resource_count(1)
      }.to raise_error(Puppet::Error)
    end
  end

  context 'with docker_tar => /tmp/docker_tars/test1.tar' do
    let(:params) { { 'docker_tar' => '/tmp/docker_tars/test1.tar' } }
    it { should contain_exec('docker load -i /tmp/docker_tars/test1.tar') }
  end

  context 'with ensure => present and docker_tar => /tmp/docker_tars/test1.tar' do
    let(:params) { { 'ensure' => 'present', 'docker_tar' => '/tmp/docker_tars/test1.tar' } }
    it { should contain_exec('docker load -i /tmp/docker_tars/test1.tar') }
  end

  context 'with docker_file => Dockerfile and docker_tar => /tmp/docker_tars/test1.tar' do
    let(:params) { { 'docker_file' => 'Dockerfile', 'docker_tar' => '/tmp/docker_tars/test1.tar' }}
    it do
      expect {
        should have_exec_resource_count(1)
      }.to raise_error(Puppet::Error)
    end
  end

  context 'with docker_tar => /tmp/docker_tars/test1.tar and docker_dir => /tmp/docker_images/test1' do
    let(:params) { { 'docker_tar' => '/tmp/docker_tars/test1.tar', 'docker_dir' => '/tmp/docker_images/test1' }}
    it do
      expect {
        should have_exec_resource_count(1)
      }.to raise_error(Puppet::Error)
    end
  end

  context 'with ensure => latest' do
    let(:params) { { 'ensure' => 'latest' } }
    it { should contain_exec('docker pull base') }
  end

  context 'with ensure => latest and image_tag => precise' do
    let(:params) { { 'ensure' => 'latest', 'image_tag' => 'precise' } }
    it { should contain_exec('docker pull base:precise') }
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
        should contain_exec('docker rmi base')
      }.to raise_error(Puppet::Error)
    end
  end
end
