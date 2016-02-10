require 'spec_helper_acceptance'

describe 'the Puppet Docker module' do
  context 'clean up before each test' do
    before(:each) do
      # Stop all container using systemd
      shell('ls -D -1 /etc/systemd/system/docker-container* | sed \'s/\/etc\/systemd\/system\///g\' | sed \'s/\.service//g\' | while read container; do service $container stop; done')
      # Delete all running containers
      shell('docker rm -f $(docker ps -a -q) || true')
      # Delete all existing images
      shell('docker rmi $(docker images -q) || true')
      # Check to make sure no images are present
      shell('docker images | wc -l') do |r|
        expect(r.stdout).to match(/^0|1$/)
      end
      # Check to make sure no running containers are present
      shell('docker ps | wc -l') do |r|
        expect(r.stdout).to match(/^0|1$/)
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
        before(:all) do
          @pp =<<-EOS
            class { 'docker':
              tcp_bind => 'tcp://127.0.0.1:4444',
            }
          EOS
          apply_manifest(@pp, :catch_failures => true)
          # A sleep to give docker time to execute properly
          sleep 4
        end

        it 'should run idempotently' do
          apply_manifest(@pp, :catch_changes => true) unless fact('selinux') == 'true'
        end

        it 'should result in docker listening on the specified address' do
          shell('netstat -tulpn | grep docker') do |r|
            expect(r.stdout).to match(/tcp\s+0\s+0\s+127.0.0.1:4444\s+0.0.0.0\:\*\s+LISTEN\s+\d+\/docker/)
          end
        end
      end

      context 'bound to a particular unix socket' do
        before(:each) do
          @pp =<<-EOS
            class { 'docker':
              socket_bind => 'unix:///var/run/docker.sock',
            }
          EOS
          apply_manifest(@pp, :catch_failures => true)
          # A sleep to give docker time to execute properly
          sleep 4
        end

        it 'should run idempotently' do
          apply_manifest(@pp, :catch_changes => true) unless fact('selinux') == 'true'
        end

        it 'should show docker listening on the specified unix socket' do
          shell('ps -aux | grep docker') do |r|
            expect(r.stdout).to match(/unix:\/\/\/var\/run\/docker.sock/)
          end
        end
      end
    end

    describe 'docker::image' do
      
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

      it 'should create a new image based on a Dockerfile' do
        pp=<<-EOS
          class { 'docker':}

          docker::image { 'ubuntu_with_file':
            docker_file => "/root/Dockerfile",
            require     => Class['docker'],
          }

          file { '/root/Dockerfile':
            ensure  => present,
            content => "FROM ubuntu\nRUN touch /root/test_file_from_dockerfile.txt",
            before  => Docker::Image['ubuntu_with_file'],
          }
        EOS

        apply_manifest(pp, :catch_failures => true)
        apply_manifest(pp, :catch_changes => true) unless fact('selinux') == 'true'

        # A sleep to give docker time to execute properly
        sleep 4

        shell("docker run ubuntu_with_file ls /root") do |r|
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
          class { 'docker': }
          docker::image { 'ubuntu_from_commit':
            docker_tar => "/root/rootfs.tar"
          }
        EOS

        apply_manifest(pp, :catch_failures => true)
        apply_manifest(pp, :catch_changes => true) unless fact('selinux') == 'true'

        # A sleep to give docker time to execute properly
        sleep 4

        # Commit currently running container as an image
        container_id = shell("docker ps | awk 'FNR == 2 {print $1}'")
        shell("docker commit #{container_id.stdout.strip} ubuntu_from_commit")

        # Stop all container using systemd
        shell('ls -D -1 /etc/systemd/system/docker-container* | sed \'s/\/etc\/systemd\/system\///g\' | sed \'s/\.service//g\' | while read container; do service $container stop; done')

        # Stop all running containers
        shell('docker rm -f $(docker ps -a -q) || true')

        # Make sure no other containers are running
        shell('docker ps | wc -l') do |r|
          expect(r.stdout).to match(/^1$/)
        end

        # Export new to a tar file
        shell("docker save ubuntu_from_commit > /root/rootfs.tar")

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

        shell("docker run ubuntu_from_commit ls /root") do |r|
          expect(r.stdout).to match(/test_file_for_tar_test.txt/)
        end
      end

      it 'should successfully delete the image' do
        pp1=<<-EOS
          class { 'docker':}
          docker::image { 'busybox':
            ensure  => present,
            require => Class['docker'],
          }
        EOS
        apply_manifest(pp1, :catch_failures => true)
        pp2=<<-EOS
          class { 'docker':}
          docker::image { 'busybox':
            ensure => absent,
          }
        EOS
        apply_manifest(pp2, :catch_failures => true)
        apply_manifest(pp2, :catch_changes => true) unless fact('selinux') == 'true'

        # A sleep to give docker time to execute properly
        sleep 4

        shell('docker images') do |r|
          expect(r.stdout).to_not match(/busybox/)
        end
      end
    end

    describe "docker::run" do
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
      end

      it 'should stop a running container and remove container' do
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
            ensure  => 'absent',
            image   => 'ubuntu',
            require => Docker::Image['ubuntu'],
          }
        EOS

        apply_manifest(pp, :catch_failures => true)
        apply_manifest(pp, :catch_changes => true) unless fact('selinux') == 'true'

        # A sleep to give docker time to execute properly
        sleep 4

        shell('docker inspect container-3-6', :acceptable_exit_codes => [0])

        apply_manifest(pp2, :catch_failures => true)
        apply_manifest(pp2, :catch_changes => true) unless fact('selinux') == 'true'

        # A sleep to give docker time to execute properly
        sleep 4

        shell('docker inspect container-3-6', :acceptable_exit_codes => [1])
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
          class { 'docker':}
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
end

