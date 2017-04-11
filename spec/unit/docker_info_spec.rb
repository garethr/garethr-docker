require 'spec_helper'
require 'facter/docker'

require 'json'

BASE_PATH = File.join(File.dirname(__FILE__), '../fixtures/data')

VER_DATA = File.read File.join(BASE_PATH, 'version.json')
INFO_DATA = File.read File.join(BASE_PATH, 'info.json')

describe 'docker_version', type: :fact do
  before do
    File.stubs(:executable?).with('/usr/local/bin/docker').returns false
    File.stubs(:executable?).with('/usr/bin/docker').returns true
  end

  context 'on linux host' do
    before do
      Facter.fact(:kernel).stubs(:value).returns('linux')
      Facter::Core::Execution.stubs(:execute).with(
        "/usr/bin/docker version --format '{{json .}}'"
      ).returns(VER_DATA)
    end

    it 'should return return hash' do
      expect(Facter.fact(:docker_version).value).to include(
        'Client' => include('Version' => '17.03.1-ce-client'),
        'Server' => include('Version' => '17.03.1-ce-server')
      )
    end
  end
end

describe 'docker_versions', type: :fact do
  context 'docker_client_version' do
    before do
      Facter.fact(:docker_version).stubs(:value).returns(JSON.parse(VER_DATA))
    end
    it do
      expect(Facter.fact(:docker_client_version).value).to eq(
        '17.03.1-ce-client'
      )
    end
  end
  context 'docker_client_version failures' do
    before do
      Facter.fact(:docker_version).stubs(:value).returns(nil)
    end
    it do
      expect(Facter.fact(:docker_server_version).value).to eq(nil)
    end
  end

  context 'docker_server_version' do
    before do
      Facter.fact(:docker_version).stubs(:value).returns(JSON.parse(VER_DATA))
    end
    it do
      expect(Facter.fact(:docker_server_version).value).to eq(
        '17.03.1-ce-server'
      )
    end
  end
end

describe 'docker_info', type: :fact do
  before do
    File.stubs(:executable?).with('/usr/local/bin/docker').returns false
    File.stubs(:executable?).with('/usr/bin/docker').returns true
  end

  context 'on linux host ' do
    before do
      Facter.fact(:kernel).stubs(:value).returns('linux')
      Facter::Core::Execution.stubs(:execute).with(
        "/usr/bin/docker info --format '{{json .}}'"
      ).returns(INFO_DATA)
    end

    it 'should return valid data' do
      expect(Facter.fact(:docker).value).to include(
        'Architecture' => 'x86_64'
      )
    end
  end
end
