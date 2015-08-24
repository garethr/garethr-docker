require 'spec_helper_acceptance'

describe 'docker' do
  case fact('osfamily')
  when 'RedHat'
    package_name = if fact('operatingsystemrelease').to_f >= 7
      'docker'
    else
      'docker-io'
    end
  else
    package_name = 'lxc-docker'
  end
  service_name = 'docker'
  command = 'docker'

  before(:all) do
    # This is a hack to work around a dependency issue
    shell('sudo yum install -y device-mapper', :pty=>true) if fact('osfamily') == 'RedHat'
  end

  context 'with default parameters' do
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
          use_name => true,
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

    describe command("#{command} images"), :sudo => true do
      its(:exit_status) { should eq 0 }
      its(:stdout) { should match /nginx/ }
    end

    describe command("#{command} ps -l --no-trunc=true"), :sudo => true do
      its(:exit_status) { should eq 0 }
      its(:stdout) { should match /nginx -g 'daemon off;'/ }
    end

    describe command("#{command} ps"), :sudo => true do
      its(:exit_status) { should eq 0 }
      its(:stdout) { should match /nginx3/ }
    end

    describe command("#{command} inspect nginx3"), :sudo => true do
      its(:exit_status) { should eq 0 }
    end

    describe command("#{command} ps --no-trunc | grep `cat /var/run/docker-nginx2.cid`"), :sudo => true do
      its(:exit_status) { should eq 0 }
      its(:stdout) { should match /nginx -g 'daemon off;'/ }
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

  context 'registry' do
    before(:all) do
      registry_host = 'localhost'
      registry_port = 5000
      @registry_address = "#{registry_host}:#{registry_port}"
      @registry_email = 'user@example.com'
      @config_file = shell('docker --version|cut -d"/" -f2').stdout < "1.7" ? '~/.dockercfg' : '~/.docker/config.json'
      @manifest = <<-EOS
        class { 'docker': }
        docker::run { 'registry':
          image         => 'registry',
          pull_on_start => true,
          ports         => '#{registry_port}:#{registry_port}',
          volumes       => '/tmp/registry-dev',
        }
      EOS

      apply_manifest(@manifest, :catch_failures=>true)
      # avoid a race condition with the registry taking time to start
      # on some operating systems
      sleep 4
    end

    it 'should be able to login to the registry' do
      manifest = <<-EOS
        docker::registry { '#{@registry_address}':
          username => 'username',
          password => 'password',
          email    => '#{@registry_email}',
        }
      EOS
      apply_manifest(manifest, :catch_failures=>true)
      shell("grep #{@registry_address} #{@config_file}", :acceptable_exit_codes => [0])
      shell("grep #{@registry_email} #{@config_file}", :acceptable_exit_codes => [0])
    end

    it 'should be able to logout from the registry' do
      manifest = <<-EOS
        docker::registry { '#{@registry_address}':
          ensure=> absent,
        }
      EOS
      apply_manifest(manifest, :catch_failures=>true)
      shell("grep #{@registry_address} #{@config_file}", :acceptable_exit_codes => [1,2])
      shell("grep #{@registry_email} #{@config_file}", :acceptable_exit_codes => [1,2])
    end

  end

end
