require 'spec_helper_acceptance'

describe 'docker network' do
  command = 'docker'

  before(:all) do
    install_code = "class { 'docker': }"
    apply_manifest(install_code, :catch_failures=>true)
  end

  describe command("#{command} network help") do
    its(:exit_status) { should eq 0 }
  end

  context 'with a local bridge network described in Puppet' do
    before(:all) do
      @name = 'test-network'
      @pp = <<-code
        docker_network { '#{@name}':
          ensure => present,
        }
      code
      apply_manifest(@pp, :catch_failures=>true)
    end

    it 'should be idempotent' do
      apply_manifest(@pp, :catch_changes=>true)
    end

    it 'should have created a network' do
      shell("#{command} network inspect #{@name}", :acceptable_exit_codes => [0])
    end

    after(:all) do
      shell("#{command} network rm #{@name}")
    end
  end
end
