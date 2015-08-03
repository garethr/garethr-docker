require 'spec_helper_acceptance'

describe 'the Puppet Docker module' do
  before(:all) do
    if default['platform'] =~ /el-7/
      pp=<<-EOS
        package {'device-mapper':
          ensure => latest,
        }
      EOS
      apply_manifest(pp, :catch_failures => true)
    end
  end

  describe 'docker class' do
    context 'without any parameters' do
      let(:pp) {"
        class { 'docker': }
      "}

      it 'should run successfully' do
        apply_manifest(pp, :catch_failures => true)
      end

      it 'should run idempotently' do
        apply_manifest(pp, :catch_changes => true) unless fact('selinux') == 'true'
      end

      # A sleep to give docker time to execute properly
      sleep 4

      it 'should be start a docker process' do
        shell('ps -aux | grep docker') do |r|
          expect(r.stdout).to match(/\/usr\/bin\/docker/)
        end
      end

      it 'should install a working docker client' do
        shell('docker ps', :acceptable_exit_codes => [0])
      end
    end

    context 'passing a TCP address to bind to' do
      let(:pp) {"
        class { 'docker':
          tcp_bind => 'tcp://127.0.0.1:4444',
        }
      "}

      it 'should run successfully' do
        apply_manifest(pp, :catch_failures => true)
      end

      it 'should run idempotently' do
        apply_manifest(pp, :catch_changes => true) unless fact('selinux') == 'true'
      end

      it 'should result in docker listening on the specified address' do
        shell('netstat -tulpn | grep docker') do |r|
          expect(r.stdout).to match(/tcp\s+0\s+0\s+127.0.0.1:4444\s+0.0.0.0\:\*\s+LISTEN\s+\d+\/docker/)
        end
      end
    end

    context 'bound to a particular unix socket' do
      let(:pp) {"
        class { 'docker':
          socket_bind => 'unix:///var/run/docker.sock',
        }
      "}

      it 'should run successfully' do
        apply_manifest(pp, :catch_failures => true)
      end

      it 'should run idempotently' do
        apply_manifest(pp, :catch_changes => true) unless fact('selinux') == 'true'
      end

      # A sleep to give docker time to execute properly
      sleep 4

      it 'should show docker listening on the specified unix socket' do
        shell('ps -aux | grep docker') do |r|
          expect(r.stdout).to match(/unix:\/\/\/var\/run\/docker.sock/)
        end
      end
    end
  end

  describe 'docker::image' do
    before(:each) do
      # Delete all existing images
      shell('docker rmi $(docker images -q) || true')
      # Check to make sure no images are present
      shell('docker images | wc -l') do |r|
        expect(r.stdout).to match(/^0|1$/)
      end
    end

    it 'should successfully download an image from the Docker Hub' do
      pp=<<-EOS
        class { 'docker':}
        docker::image { 'ubuntu':
          ensure  => present,
          require => Class['docker'],
        }
      EOS
      apply_manifest(pp, :catch_failures => true)
      apply_manifest(pp, :catch_changes => true) unless fact('selinux') == 'true'

      # A sleep to give docker time to execute properly
      sleep 4

      shell('docker images') do |r|
        expect(r.stdout).to match(/ubuntu/)
      end
    end

    it 'should successfully download an image based on a tag from the Docker Hub' do
      pp=<<-EOS
        class { 'docker':}
        docker::image { 'ubuntu':
          ensure    => present,
          image_tag => 'precise',
          require   => Class['docker'],
        }
      EOS
      apply_manifest(pp, :catch_failures => true)
      apply_manifest(pp, :catch_changes => true) unless fact('selinux') == 'true'

      # A sleep to give docker time to execute properly
      sleep 4

      shell('docker images') do |r|
        expect(r.stdout).to match(/ubuntu\s+precise/)
      end
    end


    context 'which cleans up any running containers' do
      after(:each) do
        # A sleep to give docker time to execute properly
        sleep 4

        # Stop all container using systemd
        shell('ls -D -1 /etc/systemd/system/docker-container* | sed \'s/\/etc\/systemd\/system\///g\' | sed \'s/\.service//g\' | while read container; do service $container stop; done')
        # Delete all running containers
        shell('docker rm -f $(docker ps -a -q) || true')
        # Check to make sure no running containers are present
        shell('docker ps | wc -l') do |r|
          expect(r.stdout).to match(/^0|1$/)
        end
      end

      it 'should create a new image based on a Dockerfile' do
        pp=<<-EOS
          class { 'docker':}

          docker::image { 'ubuntu':
            docker_file => "/root/Dockerfile",
            require     => Class['docker'],
          }

          file { '/root/Dockerfile':
            ensure  => present,
            content => "FROM ubuntu\nRUN touch /root/test_file_from_dockerfile.txt",
            before  => Docker::Image['ubuntu'],
          }
        EOS

        pp2=<<-EOS
          docker::run { 'container_2_3':
            image   => 'ubuntu',
            command => 'init',
          }
        EOS

        apply_manifest(pp, :catch_failures => true)
        apply_manifest(pp, :catch_changes => true) unless fact('selinux') == 'true'

        apply_manifest(pp2, :catch_failures => true)
        apply_manifest(pp2, :catch_changes => true) unless fact('selinux') == 'true'

        # A sleep to give docker time to execute properly
        sleep 4

        container_id = shell("docker ps | awk 'FNR == 2 {print $1}'")
        shell("docker exec #{container_id.stdout.strip} ls /root") do |r|
          expect(r.stdout).to match(/test_file_from_dockerfile.txt/)
        end
      end

      it 'should create a new image based on a tar' do
        pp=<<-EOS
          class { 'docker': }
          docker::image { 'ubuntu':
            require => Class['docker'],
            ensure  => present,
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
        apply_manifest(pp, :catch_changes => true) unless fact('selinux') == 'true'

        # A sleep to give docker time to execute properly
        sleep 4

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
        apply_manifest(pp2, :catch_changes => true) unless fact('selinux') == 'true'

        # A sleep to give docker time to execute properly
        sleep 4

        container_id = shell("docker ps | awk 'FNR == 2 {print $1}'")
        shell("docker exec #{container_id.stdout.strip} ls /root") do |r|
          expect(r.stdout).to match(/test_file_for_tar_test.txt/)
        end
      end
    end

    context 'with an existing image' do
      before(:all) do
        pp=<<-EOS
          class { 'docker':}
          docker::image { 'busybox':
            ensure  => present,
            require => Class['docker'],
          }
        EOS
        apply_manifest(pp, :catch_failures => true)
      end

      it 'should successfully delete the image' do
        pp=<<-EOS
          class { 'docker':}
          docker::image { 'busybox':
            ensure => absent,
          }
        EOS

        apply_manifest(pp, :catch_failures => true)
        apply_manifest(pp, :catch_changes => true) unless fact('selinux') == 'true'

        # A sleep to give docker time to execute properly
        sleep 4

        shell('docker images') do |r|
          expect(r.stdout).to_not match(/busybox/)
        end
      end
    end
  end


  describe "docker::run" do
    before(:each) do
      # A sleep to give docker time to execute properly
      sleep 4

      # Stop all container using systemd
      shell('ls -D -1 /etc/systemd/system/docker-container* | sed \'s/\/etc\/systemd\/system\///g\' | sed \'s/\.service//g\' | while read container; do service $container stop; done')
      # Delete all running containers
      shell('docker rm -f $(docker ps -a -q) || true')
      # Check to make sure no running containers are present
      shell('docker ps | wc -l') do |r|
        expect(r.stdout).to match(/^0|1$/)
      end
    end

    it 'should start a container with a configurable command' do
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
      apply_manifest(pp, :catch_changes => true) unless fact('selinux') == 'true'

      # A sleep to give docker time to execute properly
      sleep 4

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

    it 'should start a container with port configuration' do
      pp=<<-EOS
        class { 'docker':}

        docker::image { 'ubuntu':
          require => Class['docker'],
        }

        docker::run { 'container_3_2':
          image   => 'ubuntu',
          command => 'init',
          ports   => ['4444'],
          expose  => ['5555'],
          require => Docker::Image['ubuntu'],
        }
      EOS

      apply_manifest(pp, :catch_failures => true)
      apply_manifest(pp, :catch_changes => true) unless fact('selinux') == 'true'

      # A sleep to give docker time to execute properly
      sleep 4

      shell('docker ps') do |r|
        expect(r.stdout).to match(/"init".+5555\/tcp\, 0\.0\.0.0\:\d+\-\>4444\/tcp/)
      end

      if default['platform'] =~ /debian/ or default['platform'] =~ /ubuntu/
        shell("/etc/init.d/docker-container-3-2 status", :acceptable_exit_codes => [0])
      end
    end

    it 'should start a container with the hostname set' do
      pp=<<-EOS
        class { 'docker':}

        docker::image { 'ubuntu':
          require => Class['docker'],
        }

        docker::run { 'container_3_3':
          image    => 'ubuntu',
          command  => 'init',
          hostname => 'testdomain.com',
          require  => Docker::Image['ubuntu'],
        }
      EOS

      apply_manifest(pp, :catch_failures => true)
      apply_manifest(pp, :catch_changes => true) unless fact('selinux') == 'true'

      # A sleep to give docker time to execute properly
      sleep 4

      container_id = shell("docker ps | awk 'FNR == 2 {print $1}'")

      shell("docker exec #{container_id.stdout.strip} hostname") do |r|
        expect(r.stdout).to match(/testdomain.com/)
      end

      if default['platform'] =~ /debian/ or default['platform'] =~ /ubuntu/
        shell("/etc/init.d/docker-container-3-3 status", :acceptable_exit_codes => [0])
      end
    end

    it 'should start a container while mounting local volumes' do
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
      apply_manifest(pp, :catch_changes => true) unless fact('selinux') == 'true'

      # A sleep to give docker time to execute properly
      sleep 4

      container_id = shell("docker ps | awk 'FNR == 2 {print $1}'")
      shell("docker exec #{container_id.stdout.strip} ls /root/mnt") do |r|
        expect(r.stdout).to match(/test_mount.txt/)
      end

      if default['platform'] =~ /debian/ or default['platform'] =~ /ubuntu/
        shell("/etc/init.d/docker-container-3-4 status", :acceptable_exit_codes => [0])
      end
    end

    it 'should start multiple linked containers' do
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
      apply_manifest(pp, :catch_changes => true) unless fact('selinux') == 'true'

      # A sleep to give docker time to execute properly
      sleep 4

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
          links   => "#{container_1.stdout.strip}:the_link",
          require => Docker::Image['ubuntu'],
        }
      EOS

      apply_manifest(pp2, :catch_failures => true)
      apply_manifest(pp2, :catch_changes => true) unless fact('selinux') == 'true'

      # A sleep to give docker time to execute properly
      sleep 4

      container_2 = shell("docker ps | awk 'FNR == 2 {print $NF}'")

      container_id = shell("docker ps | awk 'FNR == 2 {print $1}'")
      shell("docker inspect -f \"{{ .HostConfig.Links }}\" #{container_id.stdout.strip}") do |r|
        expect(r.stdout).to match("/#{container_1.stdout.strip}:/#{container_2.stdout.strip}/the_link")
      end
    end

    it 'should stop a running container' do
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
      apply_manifest(pp, :catch_changes => true) unless fact('selinux') == 'true'

      # A sleep to give docker time to execute properly
      sleep 4

      shell('docker ps | wc -l') do |r|
        expect(r.stdout).to match(/^2$/)
      end

      apply_manifest(pp2, :catch_failures => true)
      apply_manifest(pp2, :catch_changes => true) unless fact('selinux') == 'true'

      # A sleep to give docker time to execute properly
      sleep 4

      shell('docker ps | wc -l') do |r|
        expect(r.stdout).to match(/^1$/)
      end

      if default['platform'] =~ /debian/ or default['platform'] =~ /ubuntu/
        shell("/etc/init.d/docker-container-3-6 status", :acceptable_exit_codes => [1])
      end
    end
  end

  describe "docker::exec" do
    it 'should run a command inside an already running container' do
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
      apply_manifest(pp, :catch_changes => true) unless fact('selinux') == 'true'

      # A sleep to give docker time to execute properly
      sleep 4

      container_1 = shell("docker ps | awk 'FNR == 2 {print $NF}'")

      pp2=<<-EOS
        docker::exec { 'test_command':
          container => '#{container_1.stdout.strip}',
          command   => 'touch /root/test_command_file.txt',
          tty       => true,
        }
      EOS

      apply_manifest(pp2, :catch_failures => true)

      # A sleep to give docker time to execute properly
      sleep 4

      container_id = shell("docker ps | awk 'FNR == 2 {print $1}'")
      shell("docker exec #{container_id.stdout.strip} ls /root") do |r|
        expect(r.stdout).to match(/test_command_file.txt/)
      end
    end
  end
end
