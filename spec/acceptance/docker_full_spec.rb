require 'spec_helper_acceptance'

describe 'Temp OS hacks' do
  if fact('operatingsystem') =~ /CentOS/
    if fact('operatingsystemmajrelease') == '7'
        pp=<<-EOS
              package {'device-mapper':
                ensure => latest,
              }
        EOS
      apply_manifest(pp, :catch_failures => true)
    end
  elsif default['platform'] =~ /el-7/
      pp=<<-EOS
            package {'device-mapper':
              ensure => latest,
            }

            package {'docker':
              install_options => ['--enablerepo=rhel7-extras'],
              ensure => latest,
              require => Package['device-mapper']
            }
      EOS
      apply_manifest(pp, :catch_failures => true)
  end
end

describe 'Testing class {\'docker\':}' do
  context 'Install and configure Docker and Docker Daemon' do
    it 'applies the manifest' do
      pp=<<-EOS
        class { 'docker': }
      EOS

      apply_manifest(pp, :catch_failures => true)
      unless fact('selinux') == 'true'
        apply_manifest(pp, :catch_changes => true)
      end
    end

    it ': should be running docker process' do
      shell('ps -aux | grep docker') do |r|
        expect(r.stdout).to match(/\/usr\/bin\/docker/)
      end
    end
    it ': should output table headers without error' do
      shell('docker ps', :acceptable_exit_codes => [0])
    end
  end 

  context 'When providing a TCP address to bind to' do
    it 'applies the manifest' do
      pp=<<-EOS
        class { 'docker': 
          tcp_bind    => 'tcp://127.0.0.1:4444',
        }
      EOS

      apply_manifest(pp, :catch_failures => true)
      unless fact('selinux') == 'true'
        apply_manifest(pp, :catch_changes => true)
      end
    end

    it ': should show docker listening' do
      shell('netstat -tulpn | grep docker') do |r|
        expect(r.stdout).to match(/tcp\s+0\s+0\s+127.0.0.1:4444\s+0.0.0.0\:\*\s+LISTEN\s+\d+\/docker/)
      end
    end
    it ': should output the table headers' do
      shell('docker ps', :acceptable_exit_codes => [0])
    end
  end  

  context 'Bound to a particular unix socket' do
    it 'applies the manifest' do
      pp=<<-EOS
        class { 'docker': 
          socket_bind => 'unix:///var/run/docker.sock',
        }
      EOS

      apply_manifest(pp, :catch_failures => true)
      unless fact('selinux') == 'true'
        apply_manifest(pp, :catch_changes => true)
      end
    end

    it ': should show docker listening on a unix socket' do
      shell('ps -aux | grep docker') do |r|
        expect(r.stdout).to match(/unix:\/\/\/var\/run\/docker.sock/)
      end
    end
    it ': should output the table headers' do
      shell('docker ps', :acceptable_exit_codes => [0])
    end
  end
end

describe 'Testing docker::image' do
  before(:each) do
    # Delete all existing images
    shell('docker rmi $(docker images -q) || true')
    # Check to make sure no images are present
    shell('docker images | wc -l') do |r|
      expect(r.stdout).to match(/^0|1$/)
    end
  end

  context 'docker::image should successfully download an image from the Docker Hub' do
    it 'runs test' do
      pp=<<-EOS
        class { 'docker':}
        docker::image { 'ubuntu':
          ensure => present,
          require => Class['docker'],
        }
      EOS

      apply_manifest(pp, :catch_failures => true)
      unless fact('selinux') == 'true'
        apply_manifest(pp, :catch_changes => true)
      end

      shell('docker images') do |r|
        expect(r.stdout).to match(/ubuntu/)
      end
    end
  end

  context 'docker::image should successfully download an image based on a tag from the Docker Hub' do
    it 'runs test' do
      pp=<<-EOS
        class { 'docker':}
        docker::image { 'ubuntu':
          ensure => present,
          image_tag => 'precise',
          require => Class['docker'],
        }
      EOS

      apply_manifest(pp, :catch_failures => true)
      unless fact('selinux') == 'true'
        apply_manifest(pp, :catch_changes => true)
      end

      shell('docker images') do |r|
        expect(r.stdout).to match(/ubuntu\s+precise/)
      end
    end
  end

  context 'docker::image should create a new image based on a Dockerfile' do
    it 'runs test' do
      pp=<<-EOS
        class { 'docker':}

        docker::image { 'ubuntu':
          docker_file => "/root/Dockerfile",
          require => Class['docker'],
        }

        file { '/root/Dockerfile':
          ensure => present,
          content => "FROM ubuntu\nRUN touch /root/test_file_from_dockerfile.txt",
          before => Docker::Image['ubuntu'],
        }
      EOS

      pp2=<<-EOS
        docker::run { 'container_2_3':
          image   => 'ubuntu',
          command => 'init',
        }
      EOS

      apply_manifest(pp, :catch_failures => true)
      unless fact('selinux') == 'true'
        apply_manifest(pp, :catch_changes => true)
      end

      apply_manifest(pp2, :catch_failures => true)
      unless fact('selinux') == 'true'
        apply_manifest(pp2, :catch_changes => true)
      end

      container_id = shell("docker ps | awk 'FNR == 2 {print $1}'")
      shell("docker exec #{container_id.stdout.strip} ls /root") do |r|
        expect(r.stdout).to match(/test_file_from_dockerfile.txt/)
      end
    end

    after(:each) do
      # Stop all container using systemd
      shell('ls -D -1 /etc/systemd/system/docker-container* | sed \'s/\/etc\/systemd\/system\///g\' | sed \'s/\.service//g\' | while read container; do service $container stop; done')
      # Delete all running containers
      shell('docker rm -f $(docker ps -a -q) || true')
      # Check to make sure no running containers are present
      shell('docker ps | wc -l') do |r|
        expect(r.stdout).to match(/^0|1$/)
      end
    end
  end

  context 'docker::image should create a new image based on a tar' do
    it 'runs test' do
      pp=<<-EOS
        class { 'docker':
        }

        docker::image { 'ubuntu':
          require => Class['docker'],
          ensure => present,
        }

        docker::run { 'container_2_4':
          image   => 'ubuntu',
          command => '/bin/sh -c "touch /root/test_file_for_tar_test.txt; while true; do echo hello world; sleep 1; done"',
          require => Docker::Image['ubuntu'],
        }
      EOS

      pp2=<<-EOS
        docker::image { 'newos':
          docker_tar => "/root/rootfs.tar"
        }

        docker::run { 'container_2_4_2':
          image   => 'newos',
          command => 'init',
          require => Docker::Image['newos'],
        }
      EOS

      apply_manifest(pp, :catch_failures => true)
      unless fact('selinux') == 'true'
        apply_manifest(pp, :catch_changes => true)
      end

      # Commit currently running container as an image called newos
      container_id = shell("docker ps | awk 'FNR == 2 {print $1}'")
      shell("docker commit #{container_id.stdout.strip} newos")

      # Stop all container using systemd
      shell('ls -D -1 /etc/systemd/system/docker-container* | sed \'s/\/etc\/systemd\/system\///g\' | sed \'s/\.service//g\' | while read container; do service $container stop; done')

      # Stop all running containers
      shell('docker rm -f $(docker ps -a -q) || true')

      # Make sure no other containers are running
      shell('docker ps | wc -l') do |r|
        expect(r.stdout).to match(/^1$/)
      end

      # Export new to a tar file
      shell("docker save newos > /root/rootfs.tar")

      # Remove all images
      shell('docker rmi $(docker images -q) || true')

      # Make sure no other images are present
      shell('docker images | wc -l') do |r|
        expect(r.stdout).to match(/^1$/)
      end

      apply_manifest(pp2, :catch_failures => true)
      unless fact('selinux') == 'true'
        apply_manifest(pp2, :catch_changes => true)
      end

      container_id = shell("docker ps | awk 'FNR == 2 {print $1}'")
      shell("docker exec #{container_id.stdout.strip} ls /root") do |r|
        expect(r.stdout).to match(/test_file_for_tar_test.txt/)
      end
    end

    after(:each) do
      # Stop all container using systemd
      shell('ls -D -1 /etc/systemd/system/docker-container* | sed \'s/\/etc\/systemd\/system\///g\' | sed \'s/\.service//g\' | while read container; do service $container stop; done')
      # Delete all running containers
      shell('docker rm -f $(docker ps -a -q) || true')
      # Check to make sure no running containers are present
      shell('docker ps | wc -l') do |r|
        expect(r.stdout).to match(/^0|1$/)
      end
    end
  end

  context 'docker::image should delete an image' do
    it 'runs test' do
      pp=<<-EOS
        class { 'docker':}
        docker::image { 'busybox':
          ensure => present,
          require => Class['docker'],
        }
      EOS

      pp2=<<-EOS
        class { 'docker':}
        docker::image { 'busybox':
          ensure => absent,
        }
      EOS

      apply_manifest(pp, :catch_failures => true)
      apply_manifest(pp2, :catch_failures => true)
      unless fact('selinux') == 'true'
        apply_manifest(pp2, :catch_changes => true)
      end

      shell('docker images') do |r|
        expect(r.stdout).to_not match(/ubuntu/)
      end
    end
  end
end


describe "Testing docker::run" do
  before(:each) do
    # Stop all container using systemd
    shell('ls -D -1 /etc/systemd/system/docker-container* | sed \'s/\/etc\/systemd\/system\///g\' | sed \'s/\.service//g\' | while read container; do service $container stop; done')
    # Delete all running containers
    shell('docker rm -f $(docker ps -a -q) || true')
    # Check to make sure no running containers are present
    shell('docker ps | wc -l') do |r|
      expect(r.stdout).to match(/^0|1$/)
    end
  end

  context 'docker::run should start a container with a configurable command' do
    it 'runs test' do
      pp=<<-EOS
        class { 'docker':
        }

        docker::image { 'ubuntu':
          require => Class['docker'],
        }

        docker::run { 'container_3_1':
          image   => 'ubuntu',
          command => '/bin/sh -c "touch /root/test_file.txt; while true; do echo hello world; sleep 1; done"',
          require => Docker::Image['ubuntu'],
        }
      EOS

      apply_manifest(pp, :catch_failures => true)
      unless fact('selinux') == 'true'
        apply_manifest(pp, :catch_changes => true)
      end

      container_id = shell("docker ps | awk 'FNR == 2 {print $1}'")
      shell("docker exec #{container_id.stdout.strip} ls /root") do |r|
        expect(r.stdout).to match(/test_file.txt/)
      end

      if default['platform'] =~ /debian/ or default['platform'] =~ /ubuntu/
        shell("/etc/init.d/docker-container-3-1 status", :acceptable_exit_codes => [0])
      end


      container_name = shell("docker ps | awk 'FNR == 2 {print $NF}'")
      expect("#{container_name.stdout.strip}").to match(/(container-3-1|container_3_1)/)

    end
  end

  context 'docker::run should start a container with port configuration' do
    it 'runs test' do
      pp=<<-EOS
        class { 'docker':}

        docker::image { 'ubuntu':
          require => Class['docker'],
        }

        docker::run { 'container_3_2':
          image   => 'ubuntu',
          command => 'init',
          ports => ['4444'],
          expose => ['5555'],
          require => Docker::Image['ubuntu'],
          }
      EOS

      apply_manifest(pp, :catch_failures => true)
      unless fact('selinux') == 'true'
        apply_manifest(pp, :catch_changes => true)
      end

      shell('docker ps') do |r|
        expect(r.stdout).to match(/"init".+5555\/tcp\, 0\.0\.0.0\:\d+\-\>4444\/tcp/)
      end

      if default['platform'] =~ /debian/ or default['platform'] =~ /ubuntu/
        shell("/etc/init.d/docker-container-3-2 status", :acceptable_exit_codes => [0])
      end
    end
  end

  context 'docker::run should start a container with the hostname set' do
    it 'runs test' do
      pp=<<-EOS
        class { 'docker':}

        docker::image { 'ubuntu':
          require => Class['docker'],
        }

        docker::run { 'container_3_3':
          image   => 'ubuntu',
          command => 'init',
          hostname => 'testdomain.com',
          require => Docker::Image['ubuntu'],
          }
      EOS

      apply_manifest(pp, :catch_failures => true)
      unless fact('selinux') == 'true'
        apply_manifest(pp, :catch_changes => true)
      end

      container_id = shell("docker ps | awk 'FNR == 2 {print $1}'")

      shell("docker exec #{container_id.stdout.strip} hostname") do |r|
        expect(r.stdout).to match(/testdomain.com/)
      end

      if default['platform'] =~ /debian/ or default['platform'] =~ /ubuntu/
        shell("/etc/init.d/docker-container-3-3 status", :acceptable_exit_codes => [0])
      end
    end
  end

  context 'docker::run should start a container while mounting local volumes' do
    it 'runs test' do
      pp=<<-EOS
        class { 'docker':}

        docker::image { 'ubuntu':
          require => Class['docker'],
        }

        docker::run { 'container_3_4':
          image   => 'ubuntu',
          command => 'init',
          volumes => ["/root:/root/mnt:rw"],
          require => Docker::Image['ubuntu'],
        }

        file { '/root/test_mount.txt':
          ensure => present,
          before => Docker::Run['container_3_4'],
        }
      EOS

      apply_manifest(pp, :catch_failures => true)
      unless fact('selinux') == 'true'
        apply_manifest(pp, :catch_changes => true)
      end

      container_id = shell("docker ps | awk 'FNR == 2 {print $1}'")
      shell("docker exec #{container_id.stdout.strip} ls /root/mnt") do |r|
        expect(r.stdout).to match(/test_mount.txt/)
      end

      if default['platform'] =~ /debian/ or default['platform'] =~ /ubuntu/
        shell("/etc/init.d/docker-container-3-4 status", :acceptable_exit_codes => [0])
      end
    end
  end

  context 'docker::run should start multiple linked containers' do
    it 'runs test' do
      pp=<<-EOS
        class { 'docker':}

        docker::image { 'ubuntu':
          require => Class['docker'],
        }

        docker::run { 'container_3_5_1':
          image   => 'ubuntu',
          command => 'init',
          require => Docker::Image['ubuntu'],
        }
      EOS

      apply_manifest(pp, :catch_failures => true)
      unless fact('selinux') == 'true'
        apply_manifest(pp, :catch_changes => true)
      end

      container_1 = shell("docker ps | awk 'FNR == 2 {print $NF}'")

      pp2=<<-EOS
      class { 'docker':}

        docker::image { 'ubuntu':
          require => Class['docker'],
        }

        docker::run { 'container_3_5_2':
          image   => 'ubuntu',
          command => 'init',
          depends => ['#{container_1.stdout.strip}'],
          links => "#{container_1.stdout.strip}:the_link",
          require => Docker::Image['ubuntu'],
        }

      EOS

      apply_manifest(pp2, :catch_failures => true)
      unless fact('selinux') == 'true'
        apply_manifest(pp2, :catch_changes => true)
      end

      container_2 = shell("docker ps | awk 'FNR == 2 {print $NF}'")

      container_id = shell("docker ps | awk 'FNR == 2 {print $1}'")
      shell("docker inspect -f \"{{ .HostConfig.Links }}\" #{container_id.stdout.strip}") do |r|
        expect(r.stdout).to match("/#{container_1.stdout.strip}:/#{container_2.stdout.strip}/the_link")
      end
    end
  end

  context 'docker::run should stop a running container' do
    it 'runs test' do
      pp=<<-EOS
        class { 'docker':}

        docker::image { 'ubuntu':
          require => Class['docker'],
        }

        docker::run { 'container_3_6':
          image   => 'ubuntu',
          command => 'init',
          require => Docker::Image['ubuntu'],
        }
      EOS

      pp2=<<-EOS
        class { 'docker':}

        docker::image { 'ubuntu':
          require => Class['docker'],
        }

        docker::run { 'container_3_6':
          image   => 'ubuntu',
          running => false,
          require => Docker::Image['ubuntu'],
        }
      EOS

      apply_manifest(pp, :catch_failures => true)
      unless fact('selinux') == 'true'
        apply_manifest(pp, :catch_changes => true)
      end

      shell('docker ps | wc -l') do |r|
        expect(r.stdout).to match(/^2$/)
      end

      apply_manifest(pp2, :catch_failures => true)
      unless fact('selinux') == 'true'
        apply_manifest(pp2, :catch_changes => true)
      end

      shell('docker ps | wc -l') do |r|
        expect(r.stdout).to match(/^1$/)
      end

      if default['platform'] =~ /debian/ or default['platform'] =~ /ubuntu/
        shell("/etc/init.d/docker-container-3-6 status", :acceptable_exit_codes => [1])
      end
    end
  end
end

describe "Testing docker::exec" do
  context 'Run a command inside an already running container' do
    it 'runs test' do
      pp=<<-EOS
        class { 'docker':}

        docker::image { 'ubuntu':
          require => Class['docker'],
        }

        docker::run { 'container_4_1':
          image   => 'ubuntu',
          command => 'init',
          require => Docker::Image['ubuntu'],
        }
      EOS

      apply_manifest(pp, :catch_failures => true)
      unless fact('selinux') == 'true'
        apply_manifest(pp, :catch_changes => true)
      end

      container_1 = shell("docker ps | awk 'FNR == 2 {print $NF}'")

      pp2=<<-EOS
        docker::exec { 'test_command':
          container => '#{container_1.stdout.strip}',
          command   => 'touch /root/test_command_file.txt',
          tty       => true,
        }
      EOS

      apply_manifest(pp2, :catch_failures => true)

      container_id = shell("docker ps | awk 'FNR == 2 {print $1}'")
      shell("docker exec #{container_id.stdout.strip} ls /root") do |r|
        expect(r.stdout).to match(/test_command_file.txt/)
      end
    end
  end
end

