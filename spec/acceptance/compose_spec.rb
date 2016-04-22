require 'spec_helper_acceptance'

describe 'docker compose' do
  before(:all) do
    install_code = <<-code
      class { 'docker': }
      class { 'docker::compose': }
    code
    apply_manifest(install_code, :catch_failures=>true)
  end

  describe command("docker-compose --help") do
    its(:exit_status) { should eq 0 }
  end

  context 'Creating compose projects' do
    before(:all) do
      @install = <<-code
docker_compose { '/tmp/docker-compose.yml':
  ensure => present,
}
      code
      apply_manifest(@install, :catch_failures=>true)
    end

    it 'should be idempotent' do
      apply_manifest(@install, :catch_changes=>true)
    end

    describe command("docker inspect tmp_compose_test_1"), :sudo => true do
      its(:exit_status) { should eq 0 }
    end
  end

  context 'Destroying compose projects' do
    before(:all) do
      install = <<-code
docker_compose { '/tmp/docker-compose.yml':
  ensure => present,
}
      code
      apply_manifest(install, :catch_failures=>true)
      @uninstall = <<-code
docker_compose { '/tmp/docker-compose.yml':
  ensure => absent,
}
      code
      apply_manifest(@uninstall, :catch_failures=>true)
    end

    it 'should be idempotent' do
      apply_manifest(@uninstall, :catch_changes=>true)
    end

    describe command("docker inspect tmp_compose_test_1"), :sudo => true do
      its(:exit_status) { should eq 1 }
    end
  end

  context 'Requesting a specific version of compose' do
    before(:all) do
      @version = '1.5.1'
      @pp = <<-code
        class { 'docker::compose':
          version => '#{@version}',
        }
      code
      apply_manifest(@pp, :catch_failures=>true)
    end

    it 'should be idempotent' do
      apply_manifest(@pp, :catch_changes=>true)
    end

    it 'should have installed the requested version' do
      shell('docker-compose --version', :acceptable_exit_codes => [0]) do |r|
        expect(r.stdout).to match(/#{@version}/)
      end
    end
  end

  context 'Removing docker compose' do
    before(:all) do
      @version = '1.7.0'
      @pp = <<-code
        class { 'docker::compose':
          ensure  => absent,
          version => '#{@version}',
        }
      code
      apply_manifest(@pp, :catch_failures=>true)
    end

    it 'should be idempotent' do
      apply_manifest(@pp, :catch_changes=>true)
    end

    it 'should have removed the relevant files' do
      shell('test -e /usr/local/bin/docker-compose', :acceptable_exit_codes => [1])
      shell("test -e /usr/local/bin/docker-compose-#{@version}", :acceptable_exit_codes => [1])
    end

    after(:all) do
      install_code = <<-code
        class { 'docker': }
        class { 'docker::compose': }
      code
      apply_manifest(install_code, :catch_failures=>true)
    end
  end
end
