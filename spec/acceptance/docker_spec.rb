require 'spec_helper_acceptance'

describe 'docker class' do
  case fact('osfamily')
  when 'RedHat'
    if fact('operatingsystemrelease').to_f >= 7
      package_name = 'docker'
    else
      package_name = 'docker-io'
    end
  else
    package_name = 'lxc-docker'
  end
  service_name = 'docker'
  command = 'docker'

  before(:all) do
    # This is a hack to work around a dependency issue
    shell('sudo yum install -y device-mapper') if fact('osfamily') == 'RedHat'
  end

  context 'default parameters' do
    let(:pp) {"
        class { 'docker':
          docker_users => [ 'testuser' ]
        }
        docker::image { 'nginx': }
        docker::run { 'nginx':
          image   => 'nginx',
          net     => 'host',
          require => Docker::Image['nginx'],
        }
        docker::run { 'nginx2':
          image   => 'nginx',
          restart => 'always',
          require => Docker::Image['nginx'],
        }
        docker::run { 'nginx3':
          image   => 'nginx',
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

    describe command("sudo #{command} ps") do
      its(:exit_status) { should eq 0 }
      its(:stdout) { should match /nginx3/ }
    end

    describe command("sudo #{command} inspect nginx3") do
      its(:exit_status) { should eq 0 }
    end

    describe command("sudo #{command} ps --no-trunc | grep `cat /var/run/docker-nginx2.cid`") do
      its(:exit_status) { should eq 0 }
      its(:stdout) { should match /nginx\:/ }
    end

    describe command('netstat -tlndp') do
      its(:exit_status) { should eq 0 }
      its(:stdout) { should match /0\.0\.0\.0\:80/ }
    end

    describe command('id testuser | grep docker') do
      its(:exit_status) { should eq 0 }
      its(:stdout) { should match /docker/ }
    end

  end
end
