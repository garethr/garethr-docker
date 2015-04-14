require 'spec_helper'

describe 'docker::system_user', :type => :define do
  let(:title) { 'testuser' }

  context 'with default' do
    let(:params) { {'create_user' => true} }
    it { should contain_user('testuser') }
    it { should contain_exec('docker-system-user-testuser').with_command(/docker testuser/) }
    it { should contain_exec('docker-system-user-testuser').with_unless(/grep -qw testuser/) }
  end

  context 'with create_user => false' do
    let(:params) { {'create_user' => false} }
    it { should contain_exec('docker-system-user-testuser').with_command(/docker testuser/) }
  end

end
