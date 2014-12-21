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
      it { should contain_service('docker-sample') }
      if (osfamily == 'Debian')
        it { should contain_service('docker-sample').with_hasrestart('false') }
        it { should contain_file(initscript).with_content(/\$docker run/) }
        it { should contain_file(initscript).with_content(/#{command}/) }
      else
        it { should contain_file(initscript).with_content(/#{command} run/).with_content(/base/) }
        it { should contain_file(initscript).with_content(/#{command} run/).with_content(/command/) }
      end

      ['p', 'dns', 'u', 'v', 'e', 'n', 'volumes-from', 'name'].each do |search|
        it { should_not contain_file(initscript).with_content(/-${search}/) }
      end
    end

    context 'when passing `depends` containers' do
      let(:params) { {'command' => 'command', 'image' => 'base', 'depends' => ['foo', 'bar']} }
      if (systemd)
        it { should contain_file(initscript).with_content(/After=.*\s+docker-foo.service/) }
        it { should contain_file(initscript).with_content(/After=.*\s+docker-bar.service/) }
        it { should contain_file(initscript).with_content(/Requires=.*\s+docker-foo.service/) }
        it { should contain_file(initscript).with_content(/Requires=.*\s+docker-bar.service/) }
      else
        it { should contain_file(initscript).with_content(/Required-Start:.*\s+docker-foo/) }
        it { should contain_file(initscript).with_content(/Required-Start:.*\s+docker-bar/) }
        it { should contain_file(initscript).with_content(/Required-Stop:.*\s+docker-foo/) }
        it { should contain_file(initscript).with_content(/Required-Stop:.*\s+docker-bar/) }
      end
    end

    context 'when lxc_conf disables swap' do
      let(:params) { {'command' => 'command', 'image' => 'base', 'lxc_conf' => 'lxc.cgroup.memory.memsw.limit_in_bytes=536870912'} }
      it { should contain_file(initscript).with_content(/-lxc-conf=\"lxc.cgroup.memory.memsw.limit_in_bytes=536870912\"/) }
    end

    context 'when `use_name` is true' do
      let(:params) { {'command' => 'command', 'image' => 'base', 'use_name' => true } }
      it { should contain_file(initscript).with_content(/ --name sample /) }
    end

    context 'when stopping the service' do
      let(:params) { {'command' => 'command', 'image' => 'base', 'running' => false} }
      it { should contain_service('docker-sample').with_ensure(false) }
    end

    context 'when passing a memory limit in bytes' do
      let(:params) { {'command' => 'command', 'image' => 'base', 'memory_limit' => '1000b'} }
      it { should contain_file(initscript).with_content(/-m 1000b/) }
    end

    context 'when passing a cpuset' do
      let(:params) { {'command' => 'command', 'image' => 'base', 'cpuset' => '3'} }
      it { should contain_file(initscript).with_content(/--cpuset=3/) }
    end

    context 'when passing a multiple cpu cpuset' do
      let(:params) { {'command' => 'command', 'image' => 'base', 'cpuset' => ['0', '3']} }
      it { should contain_file(initscript).with_content(/--cpuset=0,3/) }
    end

    context 'when not passing a cpuset' do
      let(:params) { {'command' => 'command', 'image' => 'base'} }
      it { should contain_file(initscript).without_content(/--cpuset=/) }
    end

    context 'when passing a links option' do
      let(:params) { {'command' => 'command', 'image' => 'base', 'links' => ['example:one', 'example:two']} }
      it { should contain_file(initscript).with_content(/ --link example:one --link example:two /) }
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

    context 'when passing a port to expose' do
      let(:params) { {'command' => 'command', 'image' => 'base', 'expose' => '4666'} }
      it { should contain_file(initscript).with_content(/--expose=4666/) }
    end

    context 'when connecting to shared data volumes' do
      let(:params) { {'command' => 'command', 'image' => 'base', 'volumes_from' => '6446ea52fbc9'} }
      it { should contain_file(initscript).with_content(/--volumes-from 6446ea52fbc9/) }
    end

    context 'when connecting to several shared data volumes' do
      let(:params) { {'command' => 'command', 'image' => 'base', 'volumes_from' => ['sample-linked-container-1', 'sample-linked-container-2']} }
      it { should contain_file(initscript).with_content(/--volumes-from sample-linked-container-1/) }
      it { should contain_file(initscript).with_content(/--volumes-from sample-linked-container-2/) }
    end

    context 'when passing several port numbers' do
      let(:params) { {'command' => 'command', 'image' => 'base', 'ports' => ['4444', '4555']} }
      it { should contain_file(initscript).with_content(/-p 4444/).with_content(/-p 4555/) }
    end

    context 'when passing several ports to expose' do
      let(:params) { {'command' => 'command', 'image' => 'base', 'expose' => ['4666', '4777']} }
      it { should contain_file(initscript).with_content(/--expose=4666/).with_content(/--expose=4777/) }
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
      it { should contain_file(initscript).with_content(/--dns 8.8.8.8/).with_content(/--dns 8.8.4.4/) }
    end

    context 'when passing a dns address' do
      let(:params) { {'command' => 'command', 'image' => 'base', 'dns' => '8.8.8.8'} }
      it { should contain_file(initscript).with_content(/--dns 8.8.8.8/) }
    end

    context 'when passing serveral dns search domains' do
      let(:params) { {'command' => 'command', 'image' => 'base', 'dns_search' => ['my.domain.local', 'other-domain.de']} }
      it { should contain_file(initscript).with_content(/--dns-search my.domain.local/).with_content(/--dns-search other-domain.de/) }
    end

    context 'when passing a dns search domain' do
      let(:params) { {'command' => 'command', 'image' => 'base', 'dns_search' => 'my.domain.local'} }
      it { should contain_file(initscript).with_content(/--dns-search my.domain.local/) }
    end

    context 'when disabling network' do
      let(:params) { {'command' => 'command', 'image' => 'base', 'disable_network' => true} }
      it { should contain_file(initscript).with_content(/-n false/) }
    end

    context 'when running privileged' do
      let(:params) { {'command' => 'command', 'image' => 'base', 'privileged' => true} }
      it { should contain_file(initscript).with_content(/--privileged/) }
    end

    context 'when running detached' do
      let(:params) { {'command' => 'command', 'image' => 'base', 'detach' => true} }
      it { should contain_file(initscript).with_content(/--detach=true/) }
    end

    context 'when passing serveral extra parameters' do
      let(:params) { {'command' => 'command', 'image' => 'base', 'extra_parameters' => ['--rm', '-w /tmp']} }
      it { should contain_file(initscript).with_content(/--rm/).with_content(/-w \/tmp/) }
    end

    context 'when passing an extra parameter' do
      let(:params) { {'command' => 'command', 'image' => 'base', 'extra_parameters' => '-c 4'} }
      it { should contain_file(initscript).with_content(/-c 4/) }
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

    context 'when using network mode' do
      let(:params) { {'command' => 'command', 'image' => 'nginx', 'net' => 'host'} }
      it { should contain_file(initscript).with_content(/--net host/) }
    end

    context 'with an title that will not format into a path' do
      let(:title) { 'this/that' }
      let(:params) { {'image' => 'base'} }

      if osfamily == 'Debian'
        new_initscript = '/etc/init.d/docker-this-that'
      elsif osfamily == 'Archlinux'
        new_initscript = '/etc/systemd/system/docker-this-that.service'
      else
        new_initscript = '/etc/init.d/docker-this-that'
      end

      it { should contain_service('docker-this-that') }
      it { should contain_file(new_initscript) }
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

    context 'with a missing memory unit' do
      let(:title) { 'with spaces' }
      let(:params) { {'command' => 'command', 'image' => 'base', 'memory' => '10240'} }
      it do
        expect {
          should contain_service('docker-sample')
        }.to raise_error(Puppet::Error)
      end
    end

  end
  end

end
