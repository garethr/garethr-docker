require 'spec_helper'

if ENV['DEBUG']
  Puppet::Util::Log.level = :debug
  Puppet::Util::Log.newdestination(:console)
end

describe 'docker::tag', :type => :define do
  let(:title) { 'base' }

  Puppet::Util::Log.level = :debug
  Puppet::Util::Log.newdestination(:console)

  context 'with ensure => absent' do
    let(:params) { { 'ensure' => 'absent' } }
    it { should contain_exec('docker rmi base:latest') }
  end

  context 'with ensure => absent and force => true' do
    let(:params) { { 'ensure' => 'absent', 'force' => true } }
    it { should contain_exec('docker rmi -f base:latest') }
  end

  context 'with ensure => absent and image_tag => precise' do
    let(:params) { { 'ensure' => 'absent', 'image_tag' => 'precise' } }
    it { should contain_exec('docker rmi base:precise') }
  end

  context 'with ensure => present and no new_tag' do
    let(:params) { { 'ensure' => 'present' } }
    it do
      expect { should have_exec_resource_count(1) }.to raise_error(Puppet::Error)
    end
  end

  context 'with ensure => present and new_tag set' do
    let(:params) { { 'ensure' => 'present', 'new_tag' => 'tag_new' } }
    it { should contain_exec('docker tag base:latest base:tag_new') }
  end

  context 'with ensure => present and new_image/new_tag' do
    let(:params) { { 'ensure' => 'present', 'new_image' => 'base1', 'new_tag' => 'tag_new' } }
    it { should contain_exec('docker tag base:latest base1:tag_new') }
  end

  context 'with ensure => present and image_tag to new_image/new_tag' do
    let(:params) { { 'ensure' => 'present', 'image_tag' => 'old_tag', 'new_image' => 'base1', 'new_tag' => 'tag_new' } }
    it { should contain_exec('docker tag base:old_tag base1:tag_new') } 
  end

  context 'with ensure => present and image/image_tag to new_image/new_tag' do
    let(:params) { { 'ensure' => 'present', 'image' => 'old_base', 'image_tag' => 'old_tag', 'new_image' => 'base1', 'new_tag' => 'tag_new' } }
    it { should contain_exec('docker tag old_base:old_tag base1:tag_new') }
  end

  context 'with ensure => present and image/image_tag to new_image/new_tag plus force' do
    let(:params) { { 'ensure' => 'present', 'image' => 'old_base', 'image_tag' => 'old_tag', 'new_image' => 'base1', 'new_tag' => 'tag_new', 'force' => true } }
    it { should contain_exec('docker tag -f old_base:old_tag base1:tag_new') }
  end
end
