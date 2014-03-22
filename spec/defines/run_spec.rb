require 'spec_helper'

['Debian', 'RedHat'].each do |osfamily|

  describe 'docker::run', :type => :define do
    let(:facts) { {:osfamily => osfamily} }
    let(:title) { 'sample' }

    if osfamily == 'Debian'
      initscript = '/etc/init/docker-sample.conf'
    else
      initscript = '/etc/init.d/docker-sample'
    end

    context 'passing the required params' do
      let(:params) { {'command' => 'command', 'image' => 'base'} }
      it { should contain_file(initscript).with_content(/docker run/).with_content(/base/) }
      it { should contain_file(initscript).with_content(/docker run/).with_content(/command/) }
      it { should contain_service('docker-sample') }

      ['p', 'dns', 'u', 'v', 'e', 'n', 'volumes-from', 'name'].each do |search|
        it { should_not contain_file(initscript).with_content(/-${search}/) }
      end
    end

    context 'when lxc_conf disables swap' do
      let(:params) { {'command' => 'command', 'image' => 'base', 'lxc_conf' => 'lxc.cgroup.memory.memsw.limit_in_bytes=536870912'} }
      it { should contain_file(initscript).with_content(/-lxc-conf=\"lxc.cgroup.memory.memsw.limit_in_bytes=536870912\"/) }
    end

    context 'when `use_name` is true' do
      let(:params) { {'command' => 'command', 'image' => 'base', 'use_name' => true } }
      it { should contain_file(initscript).with_content(/ -name sample /) }
    end

    context 'when stopping the service' do
      let(:params) { {'command' => 'command', 'image' => 'base', 'running' => false} }
      it { should contain_service('docker-sample').with_ensure(false) }
    end

    context 'when passing a memory limit in bytes' do
      let(:params) { {'command' => 'command', 'image' => 'base', 'memory_limit' => '1000'} }
      it { should contain_file(initscript).with_content(/-m 1000/) }
    end

    context 'when passing a links option' do
      let(:params) { {'command' => 'command', 'image' => 'base', 'links' => ['example:one', 'example:two']} }
      it { should contain_file(initscript).with_content(/ -link example:one -link example:two /) }
    end

    context 'when passing a hostname' do
      let(:params) { {'command' => 'command', 'image' => 'base', 'hostname' => 'example.com'} }
      it { should contain_file(initscript).with_content(/-h 'example.com'/) }
    end

    context 'when not passing a hostname' do
      let(:params) { {'command' => 'command', 'image' => 'base'} }
      it { should contain_file(initscript).without_content(/-h ''/) }
    end

    context 'when passing a username' do
      let(:params) { {'command' => 'command', 'image' => 'base', 'username' => 'bob'} }
      it { should contain_file(initscript).with_content(/-u 'bob'/) }
    end

    context 'when not passing a username' do
      let(:params) { {'command' => 'command', 'image' => 'base'} }
      it { should contain_file(initscript).without_content(/-u ''/) }
    end

    context 'when passing a port number' do
      let(:params) { {'command' => 'command', 'image' => 'base', 'ports' => '4444'} }
      it { should contain_file(initscript).with_content(/-p 4444/) }
    end

    context 'when connecting to shared data volumes' do
      let(:params) { {'command' => 'command', 'image' => 'base', 'volumes_from' => '6446ea52fbc9'} }
      it { should contain_file(initscript).with_content(/-volumes-from 6446ea52fbc9/) }
    end

    context 'when passing serveral port numbers' do
      let(:params) { {'command' => 'command', 'image' => 'base', 'ports' => ['4444', '4555']} }
      it { should contain_file(initscript).with_content(/-p 4444/).with_content(/-p 4555/) }
    end

    context 'when passing serveral environment variables' do
      let(:params) { {'command' => 'command', 'image' => 'base', 'env' => ['FOO=BAR', 'FOO2=BAR2']} }
      it { should contain_file(initscript).with_content(/-e FOO=BAR/).with_content(/-e FOO2=BAR2/) }
    end

    context 'when passing an environment variable' do
      let(:params) { {'command' => 'command', 'image' => 'base', 'env' => 'FOO=BAR'} }
      it { should contain_file(initscript).with_content(/-e FOO=BAR/) }
    end

    context 'when passing serveral dns addresses' do
      let(:params) { {'command' => 'command', 'image' => 'base', 'dns' => ['8.8.8.8', '8.8.4.4']} }
      it { should contain_file(initscript).with_content(/-dns 8.8.8.8/).with_content(/-dns 8.8.4.4/) }
    end

    context 'when passing a dns address' do
      let(:params) { {'command' => 'command', 'image' => 'base', 'dns' => '8.8.8.8'} }
      it { should contain_file(initscript).with_content(/-dns 8.8.8.8/) }
    end
    
    context 'when disabling network' do
      let(:params) { {'command' => 'command', 'image' => 'base', 'disable_network' => true} }
      it { should contain_file(initscript).with_content(/-n false/) }
    end



    context 'when passing a data volume' do
      let(:params) { {'command' => 'command', 'image' => 'base', 'volumes' => '/var/log'} }
      it { should contain_file(initscript).with_content(/-v \/var\/log/) }
    end

    context 'when passing serveral data volume' do
      let(:params) { {'command' => 'command', 'image' => 'base', 'volumes' => ['/var/lib/couchdb', '/var/log']} }
      it { should contain_file(initscript).with_content(/-v \/var\/lib\/couchdb/) }
      it { should contain_file(initscript).with_content(/-v \/var\/log/) }
    end

    context 'with an invalid title' do
      let(:title) { 'with spaces' }
      it do
        expect {
          should contain_service('docker-sample')
        }.to raise_error(Puppet::Error)
      end
    end

    context 'with an invalid image name' do
      let(:params) { {'command' => 'command', 'image' => 'with spaces', 'running' => 'not a boolean'} }
      it do
        expect {
          should contain_service('docker-sample')
        }.to raise_error(Puppet::Error)
      end
    end

    context 'with an invalid running value' do
      let(:title) { 'with spaces' }
      let(:params) { {'command' => 'command', 'image' => 'base', 'running' => 'not a boolean'} }
      it do
        expect {
          should contain_service('docker-sample')
        }.to raise_error(Puppet::Error)
      end
    end

    context 'with an invalid memory value' do
      let(:title) { 'with spaces' }
      let(:params) { {'command' => 'command', 'image' => 'base', 'memory' => 'not a number'} }
      it do
        expect {
          should contain_service('docker-sample')
        }.to raise_error(Puppet::Error)
      end
    end

  end

end
