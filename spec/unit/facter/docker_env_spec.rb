require 'spec_helper'
require 'facter'
require 'puppet_x/docker/docker_env'

describe 'docker_binpath fact' do
  subject(:fact) { Facter.fact(:docker_binpath) }

  before :each do
    Facter.clear
    Facter.clear_messages
  end

  context "on Windows", :if => Puppet::Util::Platform.windows? do
    it "should return the output of PuppetX::Docker::DockerEnv.bin" do
      expected_value = 'C:\somewhere\docker\resources\bin'
      PuppetX::Docker::DockerEnv.expects(:bin).returns(expected_value)

      expect(subject.value).to eq(expected_value)
    end  
    
    it "should return the default path when PuppetX::Docker::DockerEnv.bin is nil" do
      PuppetX::Docker::DockerEnv.expects(:bin).returns(nil)

      expect(subject.value).to eq("C:\\Program Files\\Docker\\Docker\\resources\\bin")
    end
  end

  context "on non-Windows platforms" do
    before :each do
      Puppet::Util::Platform.stubs(:windows?).returns(false)
    end

    it "should return the output of PuppetX::Docker::DockerEnv.bin" do
      expected_value = '/somewhere/bin'
      PuppetX::Docker::DockerEnv.expects(:bin).returns(expected_value)

      expect(subject.value).to eq(expected_value)
    end

    it "should return the default path when PuppetX::Docker::DockerEnv.bin is nil" do
      PuppetX::Docker::DockerEnv.expects(:bin).returns(nil)

      expect(subject.value).to eq('/usr/bin')
    end

  end
  
  after :each do
    Facter.clear
    Facter.clear_messages
  end
end


describe 'all_users_profile fact' do
  subject(:fact) { Facter.fact(:all_users_profile) }

  before :each do
    Facter.clear
    Facter.clear_messages
  end

  context "on Windows", :if => Puppet::Util::Platform.windows? do
    it "should return the output of PuppetX::Docker::DockerEnv.all_users_profile" do
      expected_value = 'C:\Somewhere'
      PuppetX::Docker::DockerEnv.expects(:all_users_profile).returns(expected_value)
      
      expect(subject.value).to eq(expected_value)
    end  
    
    it "should return the default path when PuppetX::Docker::DockerEnv.all_users_profile is nil" do
      PuppetX::Docker::DockerEnv.expects(:all_users_profile).returns(nil)
      
      expect(subject.value).to eq('C:\\ProgramData')
    end
  end
  
  after :each do
    Facter.clear
    Facter.clear_messages
  end
end
