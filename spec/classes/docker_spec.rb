require 'spec_helper'

describe 'docker', :type => :class do

  ['Debian', 'Ubuntu', 'RedHat', 'Archlinux', 'Gentoo'].each do |osfamily|
    context "on #{osfamily}" do

      if osfamily == 'Debian'
        let(:facts) { {
          :osfamily               => 'Debian',
          :operatingsystem        => 'Debian',
          :lsbdistid              => 'Debian',
          :lsbdistcodename        => 'wheezy',
          :kernelrelease          => '3.2.0-4-amd64',
          :operatingsystemrelease => '7.3',
          :operatingsystemmajrelease => '7',
        } }
        service_config_file = '/etc/default/docker'
        storage_config_file = '/etc/default/docker'

        context 'It should include default prerequired_packages' do
          it { should contain_package('cgroupfs-mount').with_ensure('present') }
        end
      end

      if osfamily == 'Ubuntu'
        let(:facts) { {
          :osfamily               => 'Debian',
          :operatingsystem        => 'Ubuntu',
          :lsbdistid              => 'Ubuntu',
          :lsbdistcodename        => 'maverick',
          :kernelrelease          => '3.8.0-29-generic',
          :operatingsystemrelease => '10.04',
          :operatingsystemmajrelease => '10',
        } }
        service_config_file = '/etc/default/docker'
        storage_config_file = '/etc/default/docker'

        it { should contain_service('docker').with_hasrestart('false') }
        it { should contain_file('/etc/init.d/docker').with_ensure('link').with_target('/lib/init/upstart-job') }

        context 'It should include default prerequired_packages' do
          it { should contain_package('cgroup-lite').with_ensure('present') }
          it { should contain_package('apparmor').with_ensure('present') }
        end
      end

      if osfamily == 'Ubuntu' or osfamily == 'Debian'

        it { should contain_class('apt') }
        it { should contain_package('docker').with_name('docker-engine').with_ensure('present') }
        it { should contain_apt__source('docker').with_location('http://apt.dockerproject.org/repo') }
        it { should contain_package('docker').with_install_options(nil) }

        context 'with a custom version' do
          let(:params) { {'version' => '0.5.5' } }
          it { should contain_package('docker').with_ensure('0.5.5').with_name('docker-engine') }
        end

        context 'with no upstream package source' do
          let(:params) { {'use_upstream_package_source' => false } }
          it { should_not contain_apt__source('docker') }
          it { should contain_package('docker').with_name('docker-engine') }
        end

        context 'with no upstream package source' do
          let(:params) { {'use_upstream_package_source' => false } }
          it { should_not contain_apt__source('docker') }
          it { should_not contain_class('epel') }
          it { should contain_package('docker') }
        end

        context 'when given a specific tmp_dir' do
          let(:params) {{ 'tmp_dir' => '/bigtmp' }}
          it { should contain_file('/etc/default/docker').with_content(/export TMPDIR="\/bigtmp"/) }
        end

        context 'with ip_forwaring param set to false' do
          let(:params) {{ 'ip_forward' => false }}
          it { should contain_file('/etc/default/docker').with_content(/ip-forward=false/) }
        end

        context 'with ip_masq param set to false' do
          let(:params) {{ 'ip_masq' => false }}
          it { should contain_file('/etc/default/docker').with_content(/ip-masq=false/) }
        end

        context 'with iptables param set to false' do
          let(:params) {{ 'iptables' => false }}
          it { should contain_file('/etc/default/docker').with_content(/iptables=false/) }
        end

        context 'with tcp_bind array param' do
          let(:params) {{ 'tcp_bind' => ['tcp://127.0.0.1:2375', 'tcp://10.0.0.1:2375'] }}
          it do
            should contain_file('/etc/default/docker').with_content(
              /tcp:\/\/127.0.0.1:2375 -H tcp:\/\/10.0.0.1:2375/
            )
          end
        end
        context 'with tcp_bind string param' do
          let(:params) {{ 'tcp_bind' => 'tcp://127.0.0.1:2375' }}
          it do
            should contain_file('/etc/default/docker').with_content(
              /tcp:\/\/127.0.0.1:2375/
            )
          end
        end
        context 'with tls param' do
          let(:params) {{
              'tcp_bind' => 'tcp://127.0.0.1:2375',
              'tls_enable' => true,
          }}
          it do
            should contain_file('/etc/default/docker').with_content(
              /tcp:\/\/127.0.0.1:2375/
            )
            should contain_file('/etc/default/docker').with_content(
              /--tls --tlsverify --tlscacert=\/etc\/docker\/tls\/ca.pem --tlscert=\/etc\/docker\/tls\/cert.pem --tlskey=\/etc\/docker\/tls\/key.pem/
            )
          end
        end
        context 'with tls param and without tlsverify' do
          let(:params) {{
              'tcp_bind' => 'tcp://127.0.0.1:2375',
              'tls_enable' => true,
              'tls_verify' => false,
          }}
          it do
            should contain_file('/etc/default/docker').with_content(
              /tcp:\/\/127.0.0.1:2375/
            )
            should contain_file('/etc/default/docker').with_content(
              /--tls --tlscacert=\/etc\/docker\/tls\/ca.pem --tlscert=\/etc\/docker\/tls\/cert.pem --tlskey=\/etc\/docker\/tls\/key.pem/
            )
          end
        end

        context 'with fixed_cidr and bridge params' do
          let(:params) {{ 'fixed_cidr' => '10.0.0.0/24' }}
          let(:params) {{
            'fixed_cidr'      => '10.0.0.0/24',
            'bridge'          => 'br0',
          }}
          it { should contain_file('/etc/default/docker').with_content(/fixed-cidr 10.0.0.0\/24/) }
        end

        context 'with default_gateway and bridge params' do
          let(:params) {{
            'default_gateway' => '10.0.0.1',
            'bridge'          => 'br0',
          }}
          it { should contain_file('/etc/default/docker').with_content(/default-gateway 10.0.0.1/) }
        end

        context 'with bridge param' do
          let(:params) {{ 'bridge' => 'br0' }}
          it { should contain_file('/etc/default/docker').with_content(/bridge br0/) }
        end

        context 'with custom service_name' do
          let(:params) {{ 'service_name' => 'docker.io' }}
          it { should contain_file('/etc/default/docker.io') }
        end

      end

      if osfamily == 'RedHat'
        let(:facts) { {
          :osfamily => osfamily,
          :operatingsystem => 'RedHat',
          :operatingsystemrelease => '6.5',
          :operatingsystemmajrelease => '7',
        } }
        service_config_file = '/etc/sysconfig/docker'
        storage_config_file = '/etc/sysconfig/docker-storage'

        context 'with proxy param' do
          let(:params) { {'proxy' => 'http://127.0.0.1:3128' } }
          it { should contain_file(service_config_file).with_content(/export http_proxy='http:\/\/127.0.0.1:3128'/) }
          it { should contain_file(service_config_file).with_content(/export https_proxy='http:\/\/127.0.0.1:3128'/) }
        end

        context 'with no_proxy param' do
          let(:params) { {'no_proxy' => '.github.com' } }
          it { should contain_file(service_config_file).with_content(/export no_proxy='.github.com'/) }
        end

        context 'when given a specific tmp_dir' do
          let(:params) {{ 'tmp_dir' => '/bigtmp' }}
          it { should contain_file('/etc/sysconfig/docker').with_content(/export TMPDIR="\/bigtmp"/) }
        end

        context 'with ip_forwaring param set to false' do
          let(:params) {{ 'ip_forward' => false }}
          it { should contain_file('/etc/sysconfig/docker').with_content(/ip-forward=false/) }
        end

        context 'with ip_masq param set to false' do
          let(:params) {{ 'ip_masq' => false }}
          it { should contain_file('/etc/sysconfig/docker').with_content(/ip-masq=false/) }
        end

        context 'with iptables param set to false' do
          let(:params) {{ 'iptables' => false }}
          it { should contain_file('/etc/sysconfig/docker').with_content(/iptables=false/) }
        end

        context 'with tcp_bind array param' do
          let(:params) {{ 'tcp_bind' => ['tcp://127.0.0.1:2375', 'tcp://10.0.0.1:2375'] }}
          it do
            should contain_file('/etc/sysconfig/docker').with_content(
              /tcp:\/\/127.0.0.1:2375 -H tcp:\/\/10.0.0.1:2375/)
          end
        end
        context 'with tcp_bind string param' do
          let(:params) {{ 'tcp_bind' => 'tcp://127.0.0.1:2375' }}
          it do
            should contain_file('/etc/sysconfig/docker').with_content(
              /tcp:\/\/127.0.0.1:2375/)
          end
        end
        context 'with tls param' do
          let(:params) {{
              'tcp_bind' => 'tcp://127.0.0.1:2375',
              'tls_enable' => true,
          }}
          it do
            should contain_file('/etc/sysconfig/docker').with_content(
              /tcp:\/\/127.0.0.1:2375/
            )
            should contain_file('/etc/sysconfig/docker').with_content(
              /--tls --tlsverify --tlscacert=\/etc\/docker\/tls\/ca.pem --tlscert=\/etc\/docker\/tls\/cert.pem --tlskey=\/etc\/docker\/tls\/key.pem/
            )
          end
        end
        context 'with tls param and without tlsverify' do
          let(:params) {{
              'tcp_bind' => 'tcp://127.0.0.1:2375',
              'tls_enable' => true,
              'tls_verify' => false,
          }}
          it do
            should contain_file('/etc/sysconfig/docker').with_content(
              /tcp:\/\/127.0.0.1:2375/
            )
            should contain_file('/etc/sysconfig/docker').with_content(
              /--tls --tlscacert=\/etc\/docker\/tls\/ca.pem --tlscert=\/etc\/docker\/tls\/cert.pem --tlskey=\/etc\/docker\/tls\/key.pem/
            )
          end
        end

        context 'with fixed_cidr and bridge params' do
          let(:params) {{ 'fixed_cidr' => '10.0.0.0/24' }}
          let(:params) {{
            'fixed_cidr'      => '10.0.0.0/24',
            'bridge'          => 'br0',
          }}
          it { should contain_file('/etc/sysconfig/docker').with_content(/fixed-cidr 10.0.0.0\/24/) }
        end

        context 'with default_gateway and bridge params' do
          let(:params) {{
            'default_gateway' => '10.0.0.1',
            'bridge'            => 'br0',
          }}
          it { should contain_file('/etc/sysconfig/docker').with_content(/default-gateway 10.0.0.1/) }
        end

        context 'with bridge param' do
          let(:params) {{ 'bridge' => 'br0' }}
          it { should contain_file('/etc/sysconfig/docker').with_content(/bridge br0/) }
        end

        context 'when given specific storage options' do
          let(:params) {{
            'storage_driver' => 'devicemapper',
            'dm_basesize'  => '3G'
          }}
          it { should contain_file(storage_config_file).with_content(/^(DOCKER_STORAGE_OPTIONS=" --storage-driver=devicemapper --storage-opt dm.basesize=3G)/) }
        end

        context 'It should include default prerequired_packages' do
          it { should contain_package('device-mapper').with_ensure('present') }
        end

        context 'It should install from rpm package' do
          let(:params) { {
            'manage_package'              => true,
            'use_upstream_package_source' => false,
            'package_name'                => 'docker-engine',
            'package_source'              => 'https://get.docker.com/rpm/1.7.0/centos-6/RPMS/x86_64/docker-engine-1.7.0-1.el6.x86_64.rpm'
          } }
          it do
            should contain_package('docker').with(
              'ensure' => 'present',
              'source' => 'https://get.docker.com/rpm/1.7.0/centos-6/RPMS/x86_64/docker-engine-1.7.0-1.el6.x86_64.rpm',
              'name'   => 'docker-engine'
            )
          end
        end

        context 'It should install from rpm package with docker::repo_opt set' do
          let(:params) { {
            'manage_package'              => true,
            'use_upstream_package_source' => false,
            'package_name'                => 'docker-engine',
            'package_source'              => 'https://get.docker.com/rpm/1.7.0/centos-6/RPMS/x86_64/docker-engine-1.7.0-1.el6.x86_64.rpm',
            'repo_opt'                    => '--enablerepo=rhel7-extras'
          } }
          it do
            should contain_package('docker').with(
              'ensure'          => 'present',
              'source'          => 'https://get.docker.com/rpm/1.7.0/centos-6/RPMS/x86_64/docker-engine-1.7.0-1.el6.x86_64.rpm',
              'name'            => 'docker-engine',
              'install_options' => '--enablerepo=rhel7-extras'
            )
          end
        end

        context 'It uses default docker::repo_opt' do
          let(:params) { {
            'manage_package'              => true,
            'use_upstream_package_source' => false,
            'package_name'                => 'docker-engine',
            'package_source'              => 'https://get.docker.com/rpm/1.7.0/centos-6/RPMS/x86_64/docker-engine-1.7.0-1.el6.x86_64.rpm'
          } }
          it do
            should contain_package('docker').with(
              'ensure'          => 'present',
              'source'          => 'https://get.docker.com/rpm/1.7.0/centos-6/RPMS/x86_64/docker-engine-1.7.0-1.el6.x86_64.rpm',
              'name'            => 'docker-engine',
              'install_options' => /--enablerepo/
            )
          end
        end

        context 'It allows overwriting docker::repo_opt with empty string' do
          let(:params) { {
            'manage_package'              => true,
            'use_upstream_package_source' => false,
            'package_name'                => 'docker-engine',
            'package_source'              => 'https://get.docker.com/rpm/1.7.0/centos-6/RPMS/x86_64/docker-engine-1.7.0-1.el6.x86_64.rpm',
            'repo_opt'                    => ''
          } }
          it do
            should contain_package('docker').with(
              'ensure'          => 'present',
              'source'          => 'https://get.docker.com/rpm/1.7.0/centos-6/RPMS/x86_64/docker-engine-1.7.0-1.el6.x86_64.rpm',
              'name'            => 'docker-engine',
              'install_options' => nil
            )
          end
        end

      end

      if osfamily == 'Archlinux'
        let(:facts) { {
          :osfamily => osfamily,
        } }
        service_config_file = '/etc/conf.d/docker'
        storage_config_file = '/etc/conf.d/docker'
      end

      if osfamily == 'Gentoo'
        let(:facts) { {
          :osfamily => osfamily,
        } }
        service_config_file = '/etc/conf.d/docker'
        storage_config_file = '/etc/conf.d/docker'
      end

      it { should compile.with_all_deps }
      it { should contain_class('docker::repos').that_comes_before('docker::install') }
      it { should contain_class('docker::install').that_comes_before('docker::config') }
      it { should contain_class('docker::service').that_subscribes_to('docker::config') }
      it { should contain_class('docker::config') }

      context 'with a specific docker command' do
        let(:params) {{ 'docker_command' => 'docker.io' }}
        it { should contain_file(service_config_file).with_content(/docker.io/) }
      end

      context 'with a custom package name' do
        let(:params) { {'package_name' => 'docker-custom-pkg-name' } }
        it { should contain_package('docker').with_name('docker-custom-pkg-name').with_ensure('present') }
      end

      context 'with a custom package name and version' do
        let(:params) { {
           'version'      => '0.5.5',
           'package_name' => 'docker-custom-pkg-name',
        } }
        it { should contain_package('docker').with_name('docker-custom-pkg-name').with_ensure('0.5.5') }
      end

      context 'when not managing the package' do
        let(:params) { {'manage_package' => false } }
        it { should_not contain_package('docker') }
      end

      context 'It should accept custom prerequired_packages' do
        let(:params) { {'prerequired_packages' => [ 'test_package' ],
                        'manage_package'       => false,  } }
        it { should contain_package('test_package').with_ensure('present') }
      end

      context 'with proxy param' do
        let(:params) { {'proxy' => 'http://127.0.0.1:3128' } }
        it { should contain_file(service_config_file).with_content(/export http_proxy='http:\/\/127.0.0.1:3128'\nexport https_proxy='http:\/\/127.0.0.1:3128'/) }
      end

      context 'with no_proxy param' do
        let(:params) { {'no_proxy' => '.github.com' } }
        it { should contain_file(service_config_file).with_content(/export no_proxy='.github.com'/) }
      end

      context 'with execdriver param lxc' do
        let(:params) { { 'execdriver' => 'lxc' }}
        it { should contain_file(service_config_file).with_content(/-e lxc/) }
      end

      context 'with execdriver param native' do
        let(:params) { { 'execdriver' => 'native' }}
        it { should contain_file(service_config_file).with_content(/-e native/) }
      end

      ['aufs', 'devicemapper', 'btrfs', 'overlay', 'vfs', 'zfs'].each do |driver|
        context "with #{driver} storage driver" do
          let(:params) { { 'storage_driver' => driver }}
          it { should contain_file(storage_config_file).with_content(/--storage-driver=#{driver}/) }
        end
      end

      context 'with thinpool device param' do
        let(:params) {
          { 'storage_driver' => 'devicemapper',
            'dm_thinpooldev' => '/dev/mapper/vg_test-docker--pool'
          }
        }
        it { should contain_file(storage_config_file).with_content(/--storage-opt dm\.thinpooldev=\/dev\/mapper\/vg_test-docker--pool/) }
      end

      context 'with use deferred removal param' do
        let(:params) {
          { 'storage_driver' => 'devicemapper',
            'dm_use_deferred_removal' => 'true'
          }
        }
        it { should contain_file(storage_config_file).with_content(/--storage-opt dm\.use_deferred_removal=true/) }
      end

      context 'with use deferred deletion param' do
        let(:params) {
          { 'storage_driver' => 'devicemapper',
            'dm_use_deferred_deletion' => 'true'
          }
        }
        it { should contain_file(storage_config_file).with_content(/--storage-opt dm\.use_deferred_deletion=true/) }
      end

      context 'with block discard param' do
        let(:params) {
          { 'storage_driver' => 'devicemapper',
            'dm_blkdiscard' => 'true'
          }
        }
        it { should contain_file(storage_config_file).with_content(/--storage-opt dm\.blkdiscard=true/) }
      end

      context 'with override udev sync check param' do
        let(:params) {
          { 'storage_driver' => 'devicemapper',
            'dm_override_udev_sync_check' => 'true'
          }
        }
        it { should contain_file(storage_config_file).with_content(/--storage-opt dm\.override_udev_sync_check=true/) }
      end

      context 'without execdriver param' do
        it { should_not contain_file(service_config_file).with_content(/-e lxc/) }
        it { should_not contain_file(service_config_file).with_content(/-e native/) }
      end

      context 'with multi dns param' do
        let(:params) { {'dns' => ['8.8.8.8', '8.8.4.4']} }
        it { should contain_file(service_config_file).with_content(/--dns 8.8.8.8/).with_content(/--dns 8.8.4.4/) }
      end

      context 'with dns param' do
        let(:params) { {'dns' => '8.8.8.8'} }
        it { should contain_file(service_config_file).with_content(/--dns 8.8.8.8/) }
      end

      context 'with multi dns_search param' do
        let(:params) { {'dns_search' => ['my.domain.local', 'other-domain.de']} }
        it { should contain_file(service_config_file).with_content(/--dns-search my.domain.local/).with_content(/--dns-search other-domain.de/) }
      end

      context 'with dns_search param' do
        let(:params) { {'dns_search' => 'my.domain.local'} }
        it { should contain_file(service_config_file).with_content(/--dns-search my.domain.local/) }
      end

      context 'with multi extra parameters' do
        let(:params) { {'extra_parameters' => ['--this this', '--that that'] } }
        it { should contain_file(service_config_file).with_content(/--this this/) }
        it { should contain_file(service_config_file).with_content(/--that that/) }
      end

      context 'with a string extra parameters' do
        let(:params) { {'extra_parameters' => '--this this' } }
        it { should contain_file(service_config_file).with_content(/--this this/) }
      end

      context 'with multi shell values' do
        let(:params) { {'shell_values' => ['--this this', '--that that'] } }
        it { should contain_file(service_config_file).with_content(/--this this/) }
        it { should contain_file(service_config_file).with_content(/--that that/) }
      end

      context 'with a string shell values' do
        let(:params) { {'shell_values' => '--this this' } }
        it { should contain_file(service_config_file).with_content(/--this this/) }
      end

      context 'with socket group set' do
        let(:params) { { 'socket_group' => 'notdocker' }}
        it { should contain_file(service_config_file).with_content(/-G notdocker/) }
      end

      context 'with labels set' do
        let(:params) { { 'labels' => ['storage=ssd','stage=production'] }}
        it { should contain_file(service_config_file).with_content(/--label storage=ssd/) }
        it { should contain_file(service_config_file).with_content(/--label stage=production/) }
      end

      context 'with service_state set to stopped' do
        let(:params) { {'service_state' => 'stopped'} }
        it { should contain_service('docker').with_ensure('stopped') }
      end

      context 'with a custom service name' do
        let(:params) { {'service_name' => 'docker.io'} }
        it { should contain_service('docker').with_name('docker.io') }
      end

      context 'with service_enable set to false' do
        let(:params) { {'service_enable' => 'false'} }
        it { should contain_service('docker').with_enable('false') }
      end

      context 'with service_enable set to true' do
        let(:params) { {'service_enable' => 'true'} }
        it { should contain_service('docker').with_enable('true') }
      end

      context 'with service_manage set to false' do
        let(:params) { {'manage_service' => false} }
        it { should_not contain_service('docker') }
      end

      context 'with specific log_level' do
        let(:params) { { 'log_level' => 'debug' } }
        it { should contain_file(service_config_file).with_content(/-l debug/) }
      end

      context 'with an invalid log_level' do
        let(:params) { { 'log_level' => 'verbose'} }
        it do
          expect {
            should contain_package('docker')
          }.to raise_error(Puppet::Error, /log_level must be one of debug, info, warn, error or fatal/)
        end
      end

      context 'with specific log_driver' do
        let(:params) { { 'log_driver' => 'json-file' } }
        it { should contain_file(service_config_file).with_content(/--log-driver json-file/) }
      end

      context 'with an invalid log_driver' do
        let(:params) { { 'log_driver' => 'verbose'} }
        it do
          expect {
            should contain_package('docker')
          }.to raise_error(Puppet::Error, /log_driver must be one of none, json-file, syslog, journald, gelf or fluentd/)
        end
      end

      context 'with specific log_driver and log_opt' do
        let(:params) {
          { 'log_driver' => 'json-file',
            'log_opt' => [ 'max-size=1m','max-file=3' ]
          }
        }
        it { should contain_file(service_config_file).with_content(/--log-driver json-file/) }
        it { should contain_file(service_config_file).with_content(/--log-opt max-size=1m/) }
        it { should contain_file(service_config_file).with_content(/--log-opt max-file=3/) }
      end

      context 'without log_driver no log_opt' do
        let(:params) { { 'log_opt' => [ 'max-size=1m' ] } }
        it { should_not contain_file(service_config_file).with_content(/--log-opt max-size=1m/) }
      end

      context 'with storage_driver set to devicemapper and dm_* options set' do
        let(:params) { {'storage_driver' => 'devicemapper',
                        'dm_datadev'     => '/dev/sda',
                        'dm_metadatadev' => '/dev/sdb', } }
        it { should contain_file(storage_config_file).with_content(/dm.datadev=\/dev\/sda/) }
      end

      context 'with storage_driver unset and dm_ options set' do
        let(:params) { {'dm_datadev'     => '/dev/sda',
                        'dm_metadatadev' => '/dev/sdb', } }
        it { should raise_error(Puppet::Error, /Values for dm_ variables will be ignored unless storage_driver is set to devicemapper./) }
      end

      context 'with storage_driver and dm_basesize set' do
        let(:params) { {'storage_driver' => 'devicemapper',
                        'dm_basesize'    => '20G', }}
        it { should contain_file(storage_config_file).with_content(/dm.basesize=20G/) }
      end

      context 'with storage_driver unset and dm_basesize set' do
        let(:params) { {'dm_basesize'    => '20G' }}
        it { should raise_error(Puppet::Error, /Values for dm_ variables will be ignored unless storage_driver is set to devicemapper./) }
      end

      context 'with specific selinux_enabled parameter' do
        let(:params) { { 'selinux_enabled' => 'true' } }
        it { should contain_file(service_config_file).with_content(/--selinux-enabled=true/) }
      end

      context 'with an invalid selinux_enabled parameter' do
        let(:params) { { 'selinux_enabled' => 'yes'} }
        it do
          expect {
            should contain_package('docker')
          }.to raise_error(Puppet::Error, /selinux_enabled must be true or false/)
        end
      end

      context 'with custom root dir' do
        let(:params) { {'root_dir' => '/mnt/docker'} }
        it { should contain_file(service_config_file).with_content(/-g \/mnt\/docker/) }
      end

      context 'with ensure absent' do
        let(:params) { {'ensure' => 'absent' } }
        it { should contain_package('docker').with_ensure('absent') }
      end

      context 'with an invalid combination of devicemapper options' do
        let(:params) {
          { 'dm_datadev' => '/dev/mapper/vg_test-docker--pool_tdata',
            'dm_metadatadev' => '/dev/mapper/vg_test-docker--pool_tmeta',
            'dm_thinpooldev' => '/dev/mapper/vg_test-docker--pool'
          }
        }
        it do
          expect {
            should contain_package('docker')
          }.to raise_error(Puppet::Error, /You can use the \$dm_thinpooldev parameter, or the \$dm_datadev and \$dm_metadatadev parameter pair, but you cannot use both./)
        end
      end

    end

  end

  context 'specific to Ubuntu Maverick' do
    let(:facts) { {
      :osfamily               => 'Debian',
      :operatingsystem        => 'Ubuntu',
      :lsbdistid              => 'Ubuntu',
      :lsbdistcodename        => 'maverick',
      :kernelrelease          => '3.8.0-29-generic',
      :operatingsystemrelease => '10.04',
    } }

    context 'with no parameters' do
      it { should contain_package('linux-image-extra-3.8.0-29-generic') }
      it { should contain_package('apparmor') }
    end

    context 'with no upstream package source' do
      let(:params) { {'use_upstream_package_source' => false } }
      it { should contain_package('linux-image-extra-3.8.0-29-generic') }
    end

    context 'when not managing the kernel' do
      let(:params) { {'manage_kernel' => false} }
      it { should_not contain_package('linux-image-extra-3.8.0-29-generic') }
    end
  end

  context 'specific to Debian wheezy' do
    let(:facts) { {
      :osfamily        => 'Debian',
      :operatingsystem => 'Debian',
      :lsbdistid       => 'Debian',
      :lsbdistcodename => 'wheezy',
      :operatingsystemrelease => '7.9',
      :operatingsystemmajrelease => '7',
      :kernelrelease   => '3.12-1-amd64'
    } }

    it { should_not contain_package('linux-image-extra-3.8.0-29-generic') }
    it { should_not contain_package('linux-image-generic-lts-raring') }
    it { should_not contain_package('linux-headers-generic-lts-raring') }
    it { should contain_service('docker').without_provider }

    context 'with no upstream package source' do
      let(:params) { {'use_upstream_package_source' => false } }
      it { should_not contain_apt__source('docker') }
      it { should contain_package('docker').with_name('docker-engine') }
    end
  end

  context 'specific to RedHat' do
    let(:facts) { {
      :osfamily => 'RedHat',
      :operatingsystem => 'RedHat',
      :operatingsystemrelease => '6.5',
      :operatingsystemmajrelease => '6',
    } }

    it { should contain_class('epel') }
    it { should_not contain_yumrepo('docker') }

    context 'with no epel repo' do
      let(:params) { {'manage_epel' => false } }
      it { should_not contain_class('epel') }
    end

    it { should contain_package('docker').with_name('docker-io').with_ensure('present') }
    it { should_not contain_apt__source('docker') }
    it { should_not contain_package('linux-image-extra-3.8.0-29-generic') }

  end

  context 'RedHat 6.5 with patched Docker kernel' do
    let(:facts) { {
      :osfamily => 'RedHat',
      :operatingsystem => 'RedHat',
      :operatingsystemrelease => '6.5',
      :operatingsystemmajrelease => '6',
      :kernelversion => '2.6.32'
    } }
    it { should contain_file('/etc/sysconfig/docker').with_content(/DOCKER_NOWARN_KERNEL_VERSION=1/) }
  end

  context 'RedHat 6.5 without patched Docker kernel' do
    let(:facts) { {
      :osfamily => 'RedHat',
      :operatingsystem => 'RedHat',
      :operatingsystemrelease => '6.5',
      :operatingsystemmajrelease => '6',
      :kernelversion => '2.6.31'
    } }
    it { should_not contain_file('/etc/sysconfig/docker').with_content(/DOCKER_NOWARN_KERNEL_VERSION=1/) }
  end

  context 'specific to Fedora 21 or above' do
    let(:facts) { {
      :osfamily => 'RedHat',
      :operatingsystem => 'Family',
      :operatingsystemrelease => '21.0',
      :operatingsystemmajrelease => '21',
    } }

    it { should contain_package('docker').with_name('docker-engine') }
    it { should contain_yumrepo('docker').with_descr('Docker') }
    it { should_not contain_class('epel') }
  end

  ['RedHat', 'OracleLinux', 'Scientific', 'CentOS'].each do |operatingsystem|
    context "on #{operatingsystem}" do
      let(:facts) { {
        :osfamily => 'RedHat',
        :operatingsystem => operatingsystem,
        :operatingsystemrelease => '7.0',
        :operatingsystemmajrelease => '7',
      } }

      storage_setup_file = '/etc/sysconfig/docker-storage-setup'

      context 'with storage driver' do
        let(:params) { { 'storage_driver' => 'devicemapper' }}
        it { should contain_file(storage_setup_file).with_content(/^STORAGE_DRIVER=devicemapper/) }
      end

      context 'with storage devices' do
        let(:params) { { 'storage_devs' => '/dev/sda,/dev/sdb' }}
        it { should contain_file(storage_setup_file).with_content(/^DEVS="\/dev\/sda,\/dev\/sdb"/) }
      end

      context 'with storage volume group' do
        let(:params) { { 'storage_vg' => 'vg_test' }}
        it { should contain_file(storage_setup_file).with_content(/^VG=vg_test/) }
      end

      context 'with storage root size' do
        let(:params) { { 'storage_root_size' => '10G' }}
        it { should contain_file(storage_setup_file).with_content(/^ROOT_SIZE=10G/) }
      end

      context 'with storage data size' do
        let(:params) { { 'storage_data_size' => '10G' }}
        it { should contain_file(storage_setup_file).with_content(/^DATA_SIZE=10G/) }
      end

      context 'with storage min data size' do
        let(:params) { { 'storage_min_data_size' => '2G' }}
        it { should contain_file(storage_setup_file).with_content(/^MIN_DATA_SIZE=2G/) }
      end

      context 'with storage chunk size' do
        let(:params) { { 'storage_chunk_size' => '10G' }}
        it { should contain_file(storage_setup_file).with_content(/^CHUNK_SIZE=10G/) }
      end

      context 'with storage grow partition' do
        let(:params) { { 'storage_growpart' => 'true' }}
        it { should contain_file(storage_setup_file).with_content(/^GROWPART=true/) }
      end

      context 'with storage auto extend pool' do
        let(:params) { { 'storage_auto_extend_pool' => '1' }}
        it { should contain_file(storage_setup_file).with_content(/^AUTO_EXTEND_POOL=1/) }
      end

      context 'with storage auto extend threshold' do
        let(:params) { { 'storage_pool_autoextend_threshold' => '1' }}
        it { should contain_file(storage_setup_file).with_content(/^POOL_AUTOEXTEND_THRESHOLD=1/) }
      end

      context 'with storage auto extend percent' do
        let(:params) { { 'storage_pool_autoextend_percent' => '10' }}
        it { should contain_file(storage_setup_file).with_content(/^POOL_AUTOEXTEND_PERCENT=10/) }
      end

    end
  end

  context 'specific to RedHat 7 or above' do
    let(:facts) { {
      :osfamily => 'RedHat',
      :operatingsystem => 'RedHat',
      :operatingsystemrelease => '7.0',
      :operatingsystemmajrelease => '7',
    } }

    it { should contain_package('docker').with_name('docker-engine') }
    it { should contain_yumrepo('docker') }
    it { should_not contain_class('epel') }
    it { should contain_package('docker').with_install_options('--enablerepo=rhel7-extras') }

    let(:params) { {'proxy' => 'http://127.0.0.1:3128' } }
    service_config_file = '/etc/sysconfig/docker'
    it { should contain_file(service_config_file).with_content(/^http_proxy='http:\/\/127.0.0.1:3128'/) }
    it { should contain_file(service_config_file).with_content(/^  https_proxy='http:\/\/127.0.0.1:3128'/) }
    it { should contain_service('docker').with_provider('systemd').with_hasstatus(true).with_hasrestart(true) }
  end

  context 'specific to Oracle Linux 7 or above' do
    let(:facts) { {
      :osfamily => 'RedHat',
      :operatingsystem => 'OracleLinux',
      :operatingsystemrelease => '7.0',
      :operatingsystemmajrelease => '7',
    } }

    it { should contain_package('docker').with_name('docker-engine') }
    it { should_not contain_class('epel') }
    it { should contain_package('docker').with_install_options('--enablerepo=ol7_addons') }
  end

  context 'specific to Scientific Linux 7 or above' do
    let(:facts) { {
      :osfamily => 'RedHat',
      :operatingsystem => 'Scientific',
      :operatingsystemrelease => '7.0',
      :operatingsystemmajrelease => '7',
    } }

    it { should contain_package('docker').with_name('docker-engine') }
    it { should_not contain_class('epel') }
  end

  context 'specific to Ubuntu Precise' do
    let(:facts) { {
      :osfamily               => 'Debian',
      :lsbdistid              => 'Ubuntu',
      :operatingsystem        => 'Ubuntu',
      :lsbdistcodename        => 'precise',
      :operatingsystemrelease => '12.04',
      :kernelrelease          => '3.8.0-29-generic'
    } }
    it { should contain_package('linux-image-generic-lts-trusty') }
    it { should contain_package('linux-headers-generic-lts-trusty') }
    it { should contain_service('docker').with_provider('upstart') }
    it { should contain_package('apparmor') }
  end

  context 'specific to Ubuntu Trusty' do
    let(:facts) { {
      :osfamily               => 'Debian',
      :lsbdistid              => 'Ubuntu',
      :operatingsystem        => 'Ubuntu',
      :lsbdistcodename        => 'trusty',
      :operatingsystemrelease => '14.04',
      :kernelrelease          => '3.8.0-29-generic'
    } }
    it { should contain_service('docker').with_provider('upstart') }
    it { should contain_package('docker').with_name('docker-engine').with_ensure('present')  }
    it { should contain_package('apparmor') }
  end

  context 'newer versions of Debian and Ubuntu' do
    context 'Ubuntu >= 15.04' do
      let(:facts) { {
        :osfamily               => 'Debian',
        :lsbdistid              => 'Ubuntu',
        :operatingsystem        => 'Ubuntu',
        :lsbdistcodename        => 'trusty',
        :operatingsystemrelease => '15.04',
        :kernelrelease          => '3.8.0-29-generic'
      } }

      it { should contain_service('docker').with_provider('systemd').with_hasstatus(true).with_hasrestart(true) }
    end

    context 'Debian >= 8' do
      let(:facts) { {
        :osfamily                  => 'Debian',
        :operatingsystem           => 'Debian',
        :lsbdistid                 => 'Debian',
        :lsbdistcodename           => 'jessie',
        :kernelrelease             => '3.2.0-4-amd64',
        :operatingsystemmajrelease => '8',
      } }

      it { should contain_service('docker').with_provider('systemd').with_hasstatus(true).with_hasrestart(true) }
    end
  end


  context 'specific to older RedHat based distros' do
    let(:facts) { {
      :osfamily => 'RedHat',
      :operatingsystem => 'RedHat',
      :operatingsystemrelease => '6.4',
      :operatingsystemmajrelease => '6',
    } }
    it do
      expect {
        should contain_package('docker')
      }.to raise_error(Puppet::Error, /version to be at least 6.5/)
    end
  end

  context 'specific to Amazon Linux (based on centos6) distros' do
    let(:facts) { {
      :osfamily => 'RedHat',
      :operatingsystem => 'Amazon',
      :operatingsystemrelease => '2015.09',
      :operatingsystemmajrelease => '2015',
    } }
    it {should contain_service('docker').without_provider }
  end

  context 'with an invalid distro name' do
    let(:facts) { {:osfamily => 'Whatever'} }
    it do
      expect {
        should contain_package('docker')
      }.to raise_error(Puppet::Error, /This module only works on Debian or Red Hat based systems or on Archlinux as on Gentoo./)
    end
  end

end
