require 'spec_helper'

describe 'docker::registry', :type => :define do
  let(:title) { 'localhost:5000' }
  it { should contain_exec('auth against localhost:5000') }

  context 'with ensure => present' do
    let(:params) { { 'ensure' => 'absent' } }
    it { should contain_exec('auth against localhost:5000').with_command('docker logout localhost:5000') }
  end

  context 'with ensure => present' do
    let(:params) { { 'ensure' => 'present' } }
    it { should contain_exec('auth against localhost:5000').with_command('docker login localhost:5000') }
  end

  context 'with ensure => present and username => user1' do
    let(:params) { { 'ensure' => 'present', 'username' => 'user1' } }
    it { should contain_exec('auth against localhost:5000').with_command('docker login localhost:5000') }
  end

  context 'with ensure => present and password => secret' do
    let(:params) { { 'ensure' => 'present', 'password' => 'secret' } }
    it { should contain_exec('auth against localhost:5000').with_command('docker login localhost:5000') }
  end

  context 'with ensure => present and email => user1@example.io' do
    let(:params) { { 'ensure' => 'present', 'email' => 'user1@example.io' } }
    it { should contain_exec('auth against localhost:5000').with_command('docker login localhost:5000') }
  end

  context 'with ensure => present and username => user1, and password => secret and email => user1@example.io' do
    let(:params) { { 'ensure' => 'present', 'username' => 'user1', 'password' => 'secret', 'email' => 'user1@example.io' } }
    it { should contain_exec('auth against localhost:5000').with_command("docker login -u 'user1' -p 'secret' -e 'user1@example.io' localhost:5000") }
  end

  context 'with username => user1, and password => secret and email => user1@example.io' do
    let(:params) { { 'username' => 'user1', 'password' => 'secret', 'email' => 'user1@example.io' } }
    it { should contain_exec('auth against localhost:5000').with_command("docker login -u 'user1' -p 'secret' -e 'user1@example.io' localhost:5000") }
  end

  context 'with an invalid ensure value' do
    let(:params) { { 'ensure' => 'not present or absent' } }
    it do
      expect {
        should contain_exec('docker logout localhost:5000')
      }.to raise_error(Puppet::Error)
    end
  end
end
