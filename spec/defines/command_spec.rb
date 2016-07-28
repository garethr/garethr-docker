require 'spec_helper'

params = {
  :command => '/usr/bin/sample',
  :image   => 'base',
}

['Debian', 'RedHat', 'Archlinux'].each do |osfamily|

  describe 'docker::command', :type => :define do
    let(:title) { '/usr/bin/wrapper' }
    let(:params) { params }

    context "on #{osfamily}" do
      if osfamily == 'Debian'
        let(:facts) { {
          :osfamily               => 'Debian',
          :lsbdistid              => 'Ubuntu',
          :operatingsystem        => 'Ubuntu',
          :lsbdistcodename        => 'trusty',
          :operatingsystemrelease => '14.04',
          :kernelrelease          => '3.8.0-29-generic'
        } }
        initscript = '/etc/init.d/docker-sample'
        command = 'docker'
        systemd = false
      elsif osfamily == 'Archlinux'
        let(:facts) { {:osfamily => osfamily} }
        initscript = '/etc/systemd/system/docker-sample.service'
        command = 'docker'
        systemd = true
      elsif osfamily == 'RedHat'
        let(:facts) { {
          :osfamily => 'RedHat',
          :operatingsystem => 'RedHat',
          :operatingsystemrelease => '6.6',
          :operatingsystemmajrelease => '6',
          :kernelversion => '2.6.32',
        } }
        initscript = '/etc/init.d/docker-sample'
        command = 'docker'
        systemd = false
      else
        let(:facts) { {
          :osfamily => 'RedHat',
          :operatingsystem => 'Amazon',
          :operatingsystemrelease => '2015.09',
          :operatingsystemmajrelease => '2015',
          :kernelversion => '2.6.32',
        } }
        initscript = '/etc/init.d/docker-sample'
        command = 'docker'
        systemd = false
      end

      context 'passing the required params' do
        it { should compile.with_all_deps }
        it { should contain_file('/usr/bin/wrapper') }
        it { should contain_file('/usr/bin/wrapper').with_content(/\$docker run/) }
        it { should contain_file('/usr/bin/wrapper').with_content(/\/usr\/bin\/sample/) }
        it { should contain_file('/usr/bin/wrapper').with_mode('0755') }

        ['p', 'dns', 'H', 'dns-search', 'u', 'v', 'e', 'n', 't', 'volumes-from', 'name'].each do |search|
          it { should_not contain_file('/usr/bin/wrapper').with_content(/-${search}/) }
        end
      end

      context 'when lxc_conf disables swap' do
        let(:params) { params.merge({'lxc_conf' => 'lxc.cgroup.memory.memsw.limit_in_bytes=536870912'}) }
        it { should contain_file('/usr/bin/wrapper').with_content(/-lxc-conf=\"lxc.cgroup.memory.memsw.limit_in_bytes=536870912\"/) }
      end

      context 'when passing a memory limit in bytes' do
        let(:params) { params.merge({'memory_limit' => '1000b'}) }
        it { should contain_file('/usr/bin/wrapper').with_content(/-m 1000b/) }
      end

      context 'when passing a cpuset' do
        let(:params) { params.merge({'cpuset' => '3'}) }
        it { should contain_file('/usr/bin/wrapper').with_content(/--cpuset=3/) }
      end

      context 'when passing a multiple cpu cpuset' do
        let(:params) { params.merge({'cpuset' => ['0', '3']}) }
        it { should contain_file('/usr/bin/wrapper').with_content(/--cpuset=0,3/) }
      end

      context 'when not passing a cpuset' do
        it { should contain_file('/usr/bin/wrapper').without_content(/--cpuset=/) }
      end

      context 'when passing a links option' do
        let(:params) { params.merge({'links' => ['example:one', 'example:two']}) }
        it { should contain_file('/usr/bin/wrapper').with_content(/ --link example:one --link example:two /) }
      end

      context 'when passing a hostname' do
        let(:params) { params.merge({'hostname' => 'example.com'}) }
        it { should contain_file('/usr/bin/wrapper').with_content(/-h 'example.com'/) }
      end

      context 'when not passing a hostname' do
        it { should contain_file('/usr/bin/wrapper').without_content(/-h ''/) }
      end

      context 'when passing a username' do
        let(:params) { params.merge({'username' => 'bob'}) }
        it { should contain_file('/usr/bin/wrapper').with_content(/-u 'bob'/) }
      end

      context 'when not passing a username' do
        it { should contain_file('/usr/bin/wrapper').without_content(/-u ''/) }
      end

      context 'when passing a port number' do
        let(:params) { params.merge({'ports' => '4444'}) }
        it { should contain_file('/usr/bin/wrapper').with_content(/-p 4444/) }
      end

      context 'when passing a port to expose' do
        let(:params) { params.merge({'expose' => '4666'}) }
        it { should contain_file('/usr/bin/wrapper').with_content(/--expose=4666/) }
      end

      context 'when passing a hostentry' do
        let(:params) { params.merge({'hostentries' => 'dummyhost:127.0.0.2'}) }
        it { should contain_file('/usr/bin/wrapper').with_content(/--add-host dummyhost:127.0.0.2/) }
      end

      context 'when connecting to shared data volumes' do
        let(:params) { params.merge({'volumes_from' => '6446ea52fbc9'}) }
        it { should contain_file('/usr/bin/wrapper').with_content(/--volumes-from 6446ea52fbc9/) }
      end

      context 'when connecting to several shared data volumes' do
        let(:params) { params.merge({'volumes_from' => ['sample-linked-container-1', 'sample-linked-container-2']}) }
        it { should contain_file('/usr/bin/wrapper').with_content(/--volumes-from sample-linked-container-1/) }
        it { should contain_file('/usr/bin/wrapper').with_content(/--volumes-from sample-linked-container-2/) }
      end

      context 'when passing several port numbers' do
        let(:params) { params.merge({'ports' => ['4444', '4555']}) }
        it { should contain_file('/usr/bin/wrapper').with_content(/-p 4444/).with_content(/-p 4555/) }
      end

      context 'when passing several ports to expose' do
        let(:params) { params.merge({'expose' => ['4666', '4777']}) }
        it { should contain_file('/usr/bin/wrapper').with_content(/--expose=4666/).with_content(/--expose=4777/) }
      end

      context 'when passing several environment variables' do
        let(:params) { params.merge({'env' => ['FOO=BAR', 'FOO2=BAR2']}) }
        it { should contain_file('/usr/bin/wrapper').with_content(/-e FOO=BAR/).with_content(/-e FOO2=BAR2/) }
      end

      context 'when passing an environment variable' do
        let(:params) { params.merge({'env' => 'FOO=BAR'}) }
        it { should contain_file('/usr/bin/wrapper').with_content(/-e FOO=BAR/) }
      end

      context 'when passing several environment files' do
        let(:params) { params.merge({'env_file' => ['/etc/foo.env', '/etc/bar.env']}) }
        it { should contain_file('/usr/bin/wrapper').with_content(/--env-file \/etc\/foo.env/).with_content(/--env-file \/etc\/bar.env/) }
      end

      context 'when passing an environment file' do
        let(:params) { params.merge({'env_file' => '/etc/foo.env'}) }
        it { should contain_file('/usr/bin/wrapper').with_content(/--env-file \/etc\/foo.env/) }
      end

      context 'when passing several dns addresses' do
        let(:params) { params.merge({'dns' => ['8.8.8.8', '8.8.4.4']}) }
        it { should contain_file('/usr/bin/wrapper').with_content(/--dns 8.8.8.8/).with_content(/--dns 8.8.4.4/) }
      end

      context 'when passing a dns address' do
        let(:params) { params.merge({'dns' => '8.8.8.8'}) }
        it { should contain_file('/usr/bin/wrapper').with_content(/--dns 8.8.8.8/) }
      end

      context 'when passing several sockets to connect to' do
        let(:params) { params.merge({'socket_connect' => ['tcp://127.0.0.1:4567', 'tcp://127.0.0.2:4567']}) }
        it { should contain_file('/usr/bin/wrapper').with_content(/-H tcp:\/\/127.0.0.1:4567/) }
      end

      context 'when passing a socket to connect to' do
        let(:params) { params.merge({'socket_connect' => 'tcp://127.0.0.1:4567'}) }
        it { should contain_file('/usr/bin/wrapper').with_content(/-H tcp:\/\/127.0.0.1:4567/) }
      end

      context 'when passing several dns search domains' do
        let(:params) { params.merge({'dns_search' => ['my.domain.local', 'other-domain.de']}) }
        it { should contain_file('/usr/bin/wrapper').with_content(/--dns-search my.domain.local/).with_content(/--dns-search other-domain.de/) }
      end

      context 'when passing a dns search domain' do
        let(:params) { params.merge({'dns_search' => 'my.domain.local'}) }
        it { should contain_file('/usr/bin/wrapper').with_content(/--dns-search my.domain.local/) }
      end

      context 'when disabling network' do
        let(:params) { params.merge({'disable_network' => true}) }
        it { should contain_file('/usr/bin/wrapper').with_content(/-n false/) }
      end

      context 'when running privileged' do
        let(:params) { params.merge({'privileged' => true}) }
        it { should contain_file('/usr/bin/wrapper').with_content(/--privileged/) }
      end

      context 'should run without detached value' do
        it { should contain_file('/usr/bin/wrapper').without_content(/--detach=true/) }
      end

      context 'should be able to override detached' do
        let(:params) { params.merge({'detach' => true}) }
        it { should contain_file('/usr/bin/wrapper').with_content(/--detach=true/) }
      end

      context 'when running with a tty' do
        let(:params) { params.merge({'tty' => true}) }
        it { should contain_file('/usr/bin/wrapper').with_content(/-t/) }
      end

      context 'when passing several extra parameters' do
        let(:params) { params.merge({'extra_parameters' => ['--test', '-w /tmp']}) }
        it { should contain_file('/usr/bin/wrapper').with_content(/--test/).with_content(/-w \/tmp/) }
      end

      context 'when passing an extra parameter' do
        let(:params) { params.merge({'extra_parameters' => '-c 4'}) }
        it { should contain_file('/usr/bin/wrapper').with_content(/-c 4/) }
      end

      context 'when passing a data volume' do
        let(:params) { params.merge({'volumes' => '/var/log'}) }
        it { should contain_file('/usr/bin/wrapper').with_content(/-v \/var\/log/) }
      end

      context 'when passing several data volume' do
        let(:params) { params.merge({'volumes' => ['/var/lib/couchdb', '/var/log']}) }
        it { should contain_file('/usr/bin/wrapper').with_content(/-v \/var\/lib\/couchdb/) }
        it { should contain_file('/usr/bin/wrapper').with_content(/-v \/var\/log/) }
      end

      context 'when using network mode' do
        let(:params) { params.merge({'net' => 'host'}) }
        it { should contain_file('/usr/bin/wrapper').with_content(/--net host/) }
      end

      context 'when `pull_on_start` is true' do
        let(:params) { params.merge({'pull_on_start' => true }) }
        it { should contain_file('/usr/bin/wrapper').with_content(/docker pull base/) }
      end

      context 'when `pull_on_start` is false' do
        let(:params) { params.merge({'pull_on_start' => false }) }
        it { should_not contain_file('/usr/bin/wrapper').with_content(/docker pull base/) }
      end

      context 'when `owner` is overridden' do
        let(:params) { params.merge({'owner' => 'nobody' }) }
        it { should contain_file('/usr/bin/wrapper').with_owner('nobody') }
      end

      context 'when `group` is overridden' do
        let(:params) { params.merge({'group' => 'nogroup' }) }
        it { should contain_file('/usr/bin/wrapper').with_group('nogroup') }
      end

      context 'when `mode` is overridden' do
        let(:params) { params.merge({'mode' => '0750' }) }
        it { should contain_file('/usr/bin/wrapper').with_mode('0750') }
      end

      context 'with an title that will not format into a path' do
        let(:title) { 'this/that' }

        it do
          expect {
            should contain_file('/usr/bin/wrapper')
          }.to raise_error(Puppet::Error)
        end
      end

      context 'with an invalid image name' do
        let(:params) { params.merge({'image' => 'with spaces' }) }
        it do
          expect {
            should contain_file('/usr/bin/wrapper')
          }.to raise_error(Puppet::Error)
        end
      end

      context 'with an invalid memory value' do
        let(:params) { params.merge({'memory' => 'not a number'}) }
        it do
          expect {
            should contain_file('/usr/bin/wrapper')
          }.to raise_error(Puppet::Error)
        end
      end

      context 'with a missing memory unit' do
        let(:params) { params.merge({'memory' => '10240'}) }
        it do
          expect {
            should contain_file('/usr/bin/wrapper')
          }.to raise_error(Puppet::Error)
        end
      end

    end
  end
end
