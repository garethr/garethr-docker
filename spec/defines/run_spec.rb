require 'spec_helper'

['Debian', 'RedHat', 'Archlinux'].each do |osfamily|

  describe 'docker::run', :type => :define do
    let(:facts) { {:osfamily => osfamily} }
    let(:title) { 'sample' }

    context "on #{osfamily}" do

      if osfamily == 'Debian'
        initscript = '/etc/init.d/docker-sample'
        command = 'docker.io'
        systemd = false
      elsif osfamily == 'Archlinux'
        initscript = '/etc/systemd/system/docker-sample.service'
        command = 'docker'
        systemd = true
      else
        initscript = '/etc/init.d/docker-sample'
        command = 'docker'
        systemd = false
      end

      context 'passing the required params' do
        let(:params) { {'command' => 'command', 'image' => 'base'} }
        it do
          should contain_docker__container('sample').with(
            'command' => 'command', 'image' => 'base'
          )
        end
      end
    end
  end
end
