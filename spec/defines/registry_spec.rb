require 'spec_helper'

describe 'docker::registry', :type => :define do
  let(:title) { 'localhost:5000' }
	let(:facts) { {
		:osfamily                  => 'Debian',
		:operatingsystem           => 'Debian',
		:lsbdistid                 => 'Debian',
		:lsbdistcodename           => 'jessie',
		:kernelrelease             => '3.2.0-4-amd64',
		:operatingsystemmajrelease => '8',
	} }

  context 'with no explicit ensure' do
    it { should contain_augeas('Create config in /root for localhost:5000') }
    it { should contain_exec('Create /root/.docker for localhost:5000').with({
      :command => 'mkdir -m 0700 -p /root/.docker',
      :creates => '/root/.docker',
    })}
    it { should contain_exec('Create /root/.docker/config.json for localhost:5000').with({
      :command => "echo '{}' > /root/.docker/config.json; chmod 0600 /root/.docker/config.json",
      :creates => '/root/.docker/config.json',
    })}
  end

  context 'with ensure => absent' do
    let(:params) { { 'ensure' => 'absent' } }
    it { should contain_augeas('Remove auth entry in /root for localhost:5000') }
    it { should_not contain_exec('Create /root/.docker for localhost:5000') }
    it { should_not contain_exec('Create /root/.docker/config.json for localhost:5000') }

  end

  context 'with ensure => present' do
    it { should contain_augeas('Create config in /root for localhost:5000') }
    it { should contain_exec('Create /root/.docker for localhost:5000').with({
      :command => 'mkdir -m 0700 -p /root/.docker',
      :creates => '/root/.docker',
    })}
    it { should contain_exec('Create /root/.docker/config.json for localhost:5000').with({
      :command => "echo '{}' > /root/.docker/config.json; chmod 0600 /root/.docker/config.json",
      :creates => '/root/.docker/config.json',
    })}
  end

  context 'with an invalid ensure value' do
    let(:params) { { 'ensure' => 'not present or absent' } }
    it do
      expect {
        should contain_augeas('Create auth entry for localhost:5000')
      }.to raise_error(Puppet::Error)
    end
  end
end
