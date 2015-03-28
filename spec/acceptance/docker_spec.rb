require 'spec_helper_acceptance'

describe 'docker class' do
  case fact('osfamily')
  when 'RedHat'
    case fact('operatingsystemrelease')
    when '7.0'
      package_name = 'docker'
    else
      package_name = 'docker-io'
    end
  else
    package_name = 'lxc-docker'
  end
  service_name = 'docker'
  command = 'docker'

  context 'default parameters' do
    let(:pp) {"
        class { 'docker': }
        docker::image { 'nginx': }
        docker::run { 'nginx':
          image => 'nginx',
          net   => 'host',
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
      its(:stdout) { should match /Client version:/ }
    end

    describe command("sudo #{command} images") do
      its(:exit_status) { should eq 0 }
      its(:stdout) { should match /nginx/ }
    end

    describe command("sudo #{command} ps -l --no-trunc=true") do
      its(:exit_status) { should eq 0 }
      its(:stdout) { should match /nginx\:/ }
    end

    describe command('netstat -tlndp') do
      its(:exit_status) { should eq 0 }
      its(:stdout) { should match /0\.0\.0\.0\:80/ }
    end

  end
end
