require 'spec_helper_acceptance'

describe 'docker CRUD tests' do
  context 'docker add' do
    it 'installs docker, pulls images and runs container' do
      pp=<<-EOS
        class { 'docker':
          tcp_bind    => 'tcp://127.0.0.1:4243',
          dns => '8.8.8.8',
        }

        docker::image { 'ubuntu':
          ensure => present,
          image_tag => 'precise'
        }

        docker::run { 'demo1':
          image   => 'ubuntu',
          command => 'init',
          ports => ['4444'],
          expose => ['5555'],
          memory_limit => '200m',
          use_name => true,
          }
      EOS

      apply_manifest(pp, :catch_failures => true)
      unless fact('selinux') == 'true'
        apply_manifest(pp, :catch_changes => true)
      end
    end

    it 'should contain the output' do
      shell('docker ps') do |r|
        expect(r.stdout).to match(/ubuntu:14.04\s+"init".+5555\/tcp\, 0\.0\.0.0\:\d+\-\>4444\/tcp\s+demo1/)
      end
      shell('docker images') do |r|
        expect(r.stdout).to match(/ubuntu\s+14.04/)
      end
      shell('netstat -tulp | grep 4243') do |r|
        expect(r.stdout).to match(/tcp\s+0\s+0\s+localhost:4243\s+*:*\s+LISTEN\s+\d+\/docker/)
      end
    end
  end

  context 'docker update' do
    it 'installs docker, pulls images, runs container, and updates container' do
      pp=<<-EOS
        class { 'docker':
          tcp_bind    => 'tcp://127.0.0.1:4243',
          dns => '8.8.8.8',
        }

        docker::image { 'ubuntu':
          ensure => present,
          image_tag => 'precise'
        }

        docker::run { 'demo2':
          image   => 'ubuntu',
          command => 'init',
          ports => ['4444'],
          expose => ['5555'],
          memory_limit => '200m',
          use_name => true,
          }
      EOS

      pp2=<<-EOS
        docker::run { 'demo2':
          image   => 'ubuntu',
          command => 'init',
          ports => ['7777'],
          expose => ['8888'],
          memory_limit => '200m',
          use_name => true,
          }
      EOS

      apply_manifest(pp, :catch_failures => true)
      apply_manifest(pp2, :catch_failures => true)
      unless fact('selinux') == 'true'
        apply_manifest(pp2, :catch_changes => true)
      end
    end

    it 'should contain the output' do
      shell('docker ps') do |r|
        expect(r.stdout).to match(/ubuntu:14.04\s+"init".+8888\/tcp\, 0\.0\.0.0\:\d+\-\>7777\/tcp\s+demo2/)
      end
    end
  end

  context 'docker destroy' do
    it 'installs docker, pulls images, runs container, and destroys container' do
      pp=<<-EOS
        class { 'docker':
          tcp_bind    => 'tcp://127.0.0.1:4243',
          dns => '8.8.8.8',
        }

        docker::image { 'ubuntu':
          ensure => present,
          image_tag => 'precise'
        }

        docker::run { 'demo3':
          image   => 'ubuntu',
          command => 'init',
          ports => ['1111'],
          expose => ['2222'],
          memory_limit => '200m',
          use_name => true,
          }
      EOS

      pp2=<<-EOS
        docker::run { 'demo3':
          running => false,
          image   => 'ubuntu',
          command => 'init',
          ports => ['1111'],
          expose => ['2222'],
          memory_limit => '200m',
          use_name => true,
          }
      EOS

      apply_manifest(pp, :catch_failures => true)
      apply_manifest(pp2, :catch_failures => true)
      unless fact('selinux') == 'true'
        apply_manifest(pp2, :catch_changes => true)
      end
    end

    it 'should contain the output' do
      shell('docker ps') do |r|
        expect(r.stdout).to_not match(/ubuntu:14.04\s+"init".+2222\/tcp\, 0\.0\.0.0\:\d+\-\>1111\/tcp\s+demo3/)
      end
    end
  end
end
