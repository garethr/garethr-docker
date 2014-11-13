require 'spec_helper_acceptance'

describe 'docker class' do
  case fact('osfamily')
  when 'RedHat'
    package_name = 'docker-io'
  else
    package_name = 'lxc-docker'
  end
  service_name = 'docker'
  command = 'docker'

  context 'default parameters' do
    it 'should work with no errors' do
      pp = <<-EOS
        class { 'docker': }
        docker::image { 'nginx': }
        docker::run { 'nginx':
          image   => 'nginx',
          net   => 'host',
        }
      EOS

      # Run it twice and test for idempotency
      expect(apply_manifest(pp).exit_code).to_not eq(1)
      expect(apply_manifest(pp).exit_code).to eq(0)
    end

    describe package(package_name) do
      it { should be_installed }
    end

    describe service(service_name) do
      it { should be_enabled }
      it { should be_running }
    end

    describe command("#{command} version") do
      it { should return_exit_status 0 }
      it { should return_stdout(/Client version: /) }
    end

    describe command("sudo #{command} images") do
      it { should return_exit_status 0 }
      it { should return_stdout(/nginx/) }
    end

    describe command("sudo #{command} ps -l --no-trunc=true") do
      it { should return_exit_status 0 }
      it { should return_stdout(/nginx\:1/) }
    end

    describe command('netstat -tlndp') do
      it { should return_exit_status 0 }
      it { should return_stdout(/0\.0\.0\.0\:80/) }
    end

  end
end
