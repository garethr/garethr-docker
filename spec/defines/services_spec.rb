require 'spec_helper'

describe 'docker::services', :type => :define do
  let(:title) { 'create services' }
	let(:facts) { {
		:osfamily                  => 'Debian',
		:operatingsystem           => 'Debian',
		:lsbdistid                 => 'Debian',
		:lsbdistcodename           => 'jessie',
		:kernelrelease             => '3.2.0-4-amd64',
		:operatingsystemmajrelease => '8',
	} }

  context 'with ensure => present and service create' do
    let(:params) { {
	    'create'       => true,
	    'service_name' => 'foo',
            'image'        => 'foo:bar',
	    'publish'      => '80:80',
            'replicas'     => '5',
            'extra_params' => ['--update-delay 1m', '--restart-window 30s']	    
    } }
    it { is_expected.to compile.with_all_deps }
    it { should contain_exec('Docker service create').with_command(/docker service create/) }
  end

  context 'with ensure => present and service update' do
    let(:params) { {
	    'create'         => false,
	    'update'         => true,
            'service_name'   => 'foo',
	    'image'          => 'bar:latest',
    } }
    it { is_expected.to compile.with_all_deps }
    it { should contain_exec('Docker service update').with_command(/docker service update/) }
  end
 
  context 'with ensure => present and service scale' do
    let(:params) { {
	    'create'         => false,
	    'scale'          => true,
            'service_name'   => 'bar',
	    'replicas'       => '5',
    } }
    it { is_expected.to compile.with_all_deps }
    it { should contain_exec('Docker service scale').with_command(/docker service scale/) }
  end
 
  context 'with ensure => absent' do
    let(:params) { {
	    'ensure'         => 'absent',
	    'service_name'   => 'foo',
    } }
    it { is_expected.to compile.with_all_deps }
    it { should contain_exec('Remove service').with_command(/docker service rm/) }
  end
end
