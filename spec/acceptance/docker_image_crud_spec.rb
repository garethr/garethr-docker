require 'spec_helper_acceptance'

describe 'docker image CRUD tests' do
  context 'docker image add' do
    it 'installs docker, pulls images' do
      pp=<<-EOS
        class { 'docker':}
        docker::image { 'ubuntu':
          ensure => present,
          image_tag => 'precise'
        }
      EOS

      apply_manifest(pp, :catch_failures => true)
      unless fact('selinux') == 'true'
        apply_manifest(pp, :catch_changes => true)
      end
    end

    it 'should contain the output' do
      shell('docker images') do |r|
        expect(r.stdout).to match(/ubuntu\s+precise/)
      end
    end
  end

  context 'docker image delete' do
    it 'installs docker, pulls images, and then removes it' do
      pp=<<-EOS
        class { 'docker':}
        docker::image { 'ubuntu':
          ensure => present,
          image_tag => 'precise'
        }
      EOS

      pp2=<<-EOS
        class { 'docker':}
        docker::image { 'ubuntu':
          ensure => absent,
        }
      EOS

      apply_manifest(pp, :catch_failures => true)
      apply_manifest(pp2, :catch_failures => true)
      unless fact('selinux') == 'true'
        apply_manifest(pp2, :catch_changes => true)
      end
    end

    it 'should contain the output' do
      shell('docker images') do |r|
        expect(r.stdout).to_not match(/ubuntu\s+precise/)
      end
    end
  end
end
