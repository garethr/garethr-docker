require 'spec_helper_acceptance'

describe 'docker' do
  package_name = 'docker-engine'
  service_name = 'docker'
  command = 'docker'

  context 'with default parameters' do
    let(:pp) {"
        class { 'docker':
          docker_cs => true,
        }
        docker::image { 'nginx': }
        docker::run { 'nginx':
          image   => 'nginx',
          net     => 'host',
          require => Docker::Image['nginx'],
        }
    "}

    it 'should apply with no errors' do
      apply_manifest(pp, :catch_failures=>true)
    end

    it 'should be idempotent' do
      apply_manifest(pp, :catch_changes=>true)
    end

    describe package(package_name) do
      it { is_expected.to be_installed }
    end

    describe service(service_name) do
      it { is_expected.to be_enabled }
      it { is_expected.to be_running }
    end

    describe command("#{command} version") do
      its(:exit_status) { should eq 0 }
    end

    describe command("#{command} images"), :sudo => true do
      its(:exit_status) { should eq 0 }
      its(:stdout) { should match /nginx/ }
    end

    describe command("#{command} inspect nginx"), :sudo => true do
      its(:exit_status) { should eq 0 }
    end
  end
end
