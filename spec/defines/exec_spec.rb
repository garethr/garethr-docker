require 'spec_helper'

describe 'docker::exec', :type => :define do
  let(:title) { 'sample' }

  context 'when running detached' do
      let(:params) { {'command' => 'command', 'container' => 'container', 'detach' => true} }
      it { should contain_exec('docker exec --detach=true container command') }
  end
  
  context 'when running with tty' do
      let(:params) { {'command' => 'command', 'container' => 'container', 'tty' => true} }
      it { should contain_exec('docker exec --tty=true container command') }
  end
  
  context 'when running with interactive' do
      let(:params) { {'command' => 'command', 'container' => 'container', 'interactive' => true} }
      it { should contain_exec('docker exec --interactive=true container command') }
  end

  context 'when running with unless' do
      let(:params) { {'command' => 'command', 'container' => 'container', 'interactive' => true, 'unless' => 'some_command arg1'} }
      it { should contain_exec('docker exec --interactive=true container command').with_unless ('docker exec --interactive=true container some_command arg1') }
  end

  context 'when running without unless' do
      let(:params) { {'command' => 'command', 'container' => 'container', 'interactive' => true,} }
      it { should contain_exec('docker exec --interactive=true container command').with_unless (nil) }
  end
end
