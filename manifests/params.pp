# == Class: docker::params
#
# Default parameter values for the docker module
#
class docker::params {
  $version                           = undef
  $ensure                            = present
  $docker_cs                         = false
  $tcp_bind                          = undef
  $tls_enable                        = false
  $tls_verify                        = true
  $tls_cacert                        = '/etc/docker/tls/ca.pem'
  $tls_cert                          = '/etc/docker/tls/cert.pem'
  $tls_key                           = '/etc/docker/tls/key.pem'
  $ip_forward                        = true
  $iptables                          = true
  $icc                               = undef
  $ip_masq                           = true
  $bip                               = undef
  $mtu                               = undef
  $fixed_cidr                        = undef
  $bridge                            = undef
  $default_gateway                   = undef
  $socket_bind                       = 'unix:///var/run/docker.sock'
  $log_level                         = undef
  $log_driver                        = undef
  $log_opt                           = []
  $selinux_enabled                   = undef
  $socket_group                      = undef
  $labels                            = []
  $service_state                     = running
  $service_enable                    = true
  $manage_service                    = true
  $root_dir                          = undef
  $tmp_dir                           = '/tmp/'
  $dns                               = undef
  $dns_search                        = undef
  $proxy                             = undef
  $no_proxy                          = undef
  $execdriver                        = undef
  $storage_driver                    = undef
  $dm_basesize                       = undef
  $dm_fs                             = undef
  $dm_mkfsarg                        = undef
  $dm_mountopt                       = undef
  $dm_blocksize                      = undef
  $dm_loopdatasize                   = undef
  $dm_loopmetadatasize               = undef
  $dm_datadev                        = undef
  $dm_metadatadev                    = undef
  $dm_thinpooldev                    = undef
  $dm_use_deferred_removal           = undef
  $dm_use_deferred_deletion          = undef
  $dm_blkdiscard                     = undef
  $dm_override_udev_sync_check       = undef
  $manage_package                    = true
  $package_source                    = undef
  $manage_kernel                     = true
  $package_name_default              = 'docker-ce'
  $package_name_cs_default           = 'docker-ee'
  $service_name_default              = 'docker'
  $docker_command_default            = 'docker'
  $docker_group_default              = 'docker'
  $docker_daemon_command             = 'dockerd'
  $storage_devs                      = undef
  $storage_vg                        = undef
  $storage_root_size                 = undef
  $storage_data_size                 = undef
  $storage_min_data_size             = undef
  $storage_chunk_size                = undef
  $storage_growpart                  = undef
  $storage_auto_extend_pool          = undef
  $storage_pool_autoextend_threshold = undef
  $storage_pool_autoextend_percent   = undef
  $storage_config_template           = 'docker/etc/sysconfig/docker-storage.erb'
  $compose_version                   = '1.9.0'
  $compose_install_path              = '/usr/local/bin'


  case $::osfamily {
    'Debian' : {
      case $::operatingsystem {
        'Ubuntu' : {
          if (versioncmp($::operatingsystemrelease, '15.04') >= 0) {
            $service_provider        = 'systemd'
            $storage_config          = '/etc/default/docker-storage'
            $service_config_template = 'docker/etc/sysconfig/docker.systemd.erb'
            $service_overrides_template = 'docker/etc/systemd/system/docker.service.d/service-overrides-debian.conf.erb'
            $service_hasstatus       = true
            $service_hasrestart      = true
            include docker::systemd_reload
          } else {
            $service_config_template = 'docker/etc/default/docker.erb'
            $service_overrides_template = undef
            $service_provider        = 'upstart'
            $service_hasstatus       = true
            $service_hasrestart      = false
            $storage_config          = undef
          }
        }
        default: {
          if (versioncmp($::operatingsystemmajrelease, '8') >= 0) {
            $service_provider           = 'systemd'
            $storage_config             = '/etc/default/docker-storage'
            $service_config_template    = 'docker/etc/sysconfig/docker.systemd.erb'
            $service_overrides_template = 'docker/etc/systemd/system/docker.service.d/service-overrides-debian.conf.erb'
            $service_hasstatus          = true
            $service_hasrestart         = true
            include docker::systemd_reload
          } else {
            $service_provider           = undef
            $storage_config             = undef
            $service_config_template    = 'docker/etc/default/docker.erb'
            $service_overrides_template = undef
            $service_hasstatus          = undef
            $service_hasrestart         = undef
          }
        }
      }

      $manage_epel = false
      $service_name = $service_name_default
      $docker_command = $docker_command_default
      $docker_group = $docker_group_default
      $use_upstream_package_source = true
      $pin_upstream_package_source = true
      $apt_source_pin_level = 10
      $repo_opt = undef
      $nowarn_kernel = false
      $service_config = undef
      $storage_setup_file = undef

      $package_release = $::lsbdistcodename
      $package_os = downcase($::operatingsystem)

      $package_name = $docker_cs ? {
        true    => $package_name_cs_default,
        default => $package_name_default
      }

      # package_repos:
      # For CE: edge, stable, test.
      # For EE, fx stable-17.09. Must be set explicitly.
      $package_repos = $docker_cs ? {
        true    => undef,
        default => 'stable'
      }

      $package_source_location =  $docker_cs ? {
        true    => undef,
        default => "https://download.docker.com/linux/${package_os}"
      }

      $package_key_source = $docker_cs ? {
        true    => undef,
        default => "${package_source_location}/gpg"
      }

      $package_key =  $docker_cs ? {
        true => 'DD911E995A64A202E85907D6BC14F10B6D085F96',
        default => '9DC858229FC7DD38854AE2D88D81803C0EBFCD88'
      }

      $purge_packages = ['docker-engine', 'docker.io']

      if ($::operatingsystem == 'Debian' and versioncmp($::operatingsystemmajrelease, '8') >= 0) or
        ($::operatingsystem == 'Ubuntu' and versioncmp($::operatingsystemrelease, '15.04') >= 0) {
        $detach_service_in_init = false
      } else {
        $detach_service_in_init = true
      }

    }
    'RedHat' : {
      $service_config = '/etc/sysconfig/docker'
      $storage_config = '/etc/sysconfig/docker-storage'
      $storage_setup_file = '/etc/sysconfig/docker-storage-setup'
      $service_hasstatus  = true
      $service_hasrestart = true

      if ($::operatingsystem == 'Fedora') or (versioncmp($::operatingsystemrelease, '7.0') >= 0) and $::operatingsystem != 'Amazon' {
        $service_provider           = 'systemd'
        $service_config_template    = 'docker/etc/sysconfig/docker.systemd.erb'
        $service_overrides_template = 'docker/etc/systemd/system/docker.service.d/service-overrides-rhel.conf.erb'
      } else {
        $service_config_template    = 'docker/etc/sysconfig/docker.erb'
        $service_provider           = undef
        $service_overrides_template = undef
      }

      if (versioncmp($::operatingsystemrelease, '7.0') < 0) and $::operatingsystem != 'Amazon' {
        $use_upstream_package_source = false
        $manage_epel = true
      } elsif $::operatingsystem == 'Amazon' {
        $use_upstream_package_source = false
        $manage_epel = false
      } else {
        $use_upstream_package_source = true
        $manage_epel = false
      }

      $package_os = downcase($::operatingsystem)
      case $docker_cs {
        true : {
          $package_repos = undef
          $package_source_location = undef
          $package_key = undef
          $package_key_source = undef
          $purge_packages = ['docker-common', 'docker-selinux', 'docker-engine-selinux', 'docker-engine','docker-ce']
        }
        default : {
          $package_repos = 'stable'
          $package_source_location = $::operatingsystem ? {
            /(CentOS|Fedora)/ => "https://download.docker.com/linux/${package_os}/${::operatingsystemmajrelease}/${::architecture}/${package_repos}",
            default           => undef
          }
          $package_key =  $::operatingsystem ? {
            /(CentOS|Fedora)/ => '060A61C51B558A7F742B77AAC52FEB6B621E9F35',
            default           => undef,
          }
          $package_key_source = $::operatingsystem ? {
            /(CentOS|Fedora)/ => "https://download.docker.com/linux/${package_os}/gpg",
            default => undef
          }
          $purge_packages = $::operatingsystem ? {
            'CentOS' => ['docker-common', 'docker-selinux', 'docker-engine'],
            'Fedora' => ['docker-common', 'docker-selinux', 'docker-engine', 'docker-engine-selinux'],
            default  => ['docker-common', 'docker-selinux', 'docker-engine', 'docker-engine-selinux'],
          }
        }
      }

      $package_name = $docker_cs ? {
        true    => $package_name_cs_default,
        default => $package_name_default,
      }

      $package_release = undef
      $pin_upstream_package_source = undef
      $apt_source_pin_level = undef
      $service_name = $service_name_default
      $docker_command = $docker_command_default
      if (versioncmp($::operatingsystemrelease, '7.0') < 0) or ($::operatingsystem == 'Amazon') {
        $detach_service_in_init = true
        if $::operatingsystem == 'OracleLinux' {
          $docker_group = 'dockerroot'
        } else {
          $docker_group = $docker_group_default
        }
      } else {
        $detach_service_in_init = false
        if $use_upstream_package_source {
          $docker_group = $docker_group_default
        } else {
          $docker_group = 'dockerroot'
        }
        include docker::systemd_reload
      }

      # repo_opt to specify install_options for docker package
      if (versioncmp($::operatingsystemmajrelease, '7') == 0) {
        if $::operatingsystem == 'RedHat' {
          $repo_opt = '--enablerepo=rhel7-extras'
        } elsif $::operatingsystem == 'CentOS' {
          $repo_opt = '--enablerepo=extras'
        } elsif $::operatingsystem == 'OracleLinux' {
          $repo_opt = '--enablerepo=ol7_addons'
        } elsif $::operatingsystem == 'Scientific' {
          $repo_opt = ''
        } else {
          $repo_opt = undef
        }
      } elsif (versioncmp($::operatingsystemrelease, '7.0') < 0 and $::operatingsystem == 'OracleLinux') {
          # FIXME is 'public_ol6_addons' available on all OL6 installs?
          $repo_opt = '--enablerepo=public_ol6_addons,public_ol6_latest'
      } else {
        $repo_opt = undef
      }
      if $::kernelversion == '2.6.32' {
        $nowarn_kernel = true
      } else {
        $nowarn_kernel = false
      }
    }
    'Archlinux' : {
      include docker::systemd_reload

      $manage_epel = false
      $docker_group = $docker_group_default
      $package_name = undef
      $package_key_source = undef
      $package_source_location = undef
      $package_key = undef
      $package_repos = undef
      $package_release = undef
      $purge_packages = undef
      $use_upstream_package_source = false
      $service_name = $service_name_default
      $docker_command = $docker_command_default
      $detach_service_in_init = false
      $repo_opt = undef
      $nowarn_kernel = false
      $service_provider   = 'systemd'
      $service_overrides_template = 'docker/etc/systemd/system/docker.service.d/service-overrides-archlinux.conf.erb'
      $service_hasstatus  = true
      $service_hasrestart = true
      $service_config = '/etc/conf.d/docker'
      $service_config_template = 'docker/etc/conf.d/docker.erb'
      $storage_config = undef
      $storage_setup_file = undef
      $pin_upstream_package_source = undef
      $apt_source_pin_level = undef
    }
    'Gentoo' : {
      $manage_epel = false
      $docker_group = $docker_group_default
      $package_key_source = undef
      $package_source_location = undef
      $package_key = undef
      $package_repos = undef
      $package_release = undef
      $purge_packages = undef
      $use_upstream_package_source = false
      $package_name = 'app-emulation/docker'
      $service_name = $service_name_default
      $docker_command = $docker_command_default
      $detach_service_in_init = true
      $repo_opt = undef
      $nowarn_kernel = false
      $service_provider   = 'openrc'
      $service_overrides_template = 'docker/etc/systemd/system/docker.service.d/service-overrides-archlinux.conf.erb'
      $service_hasstatus  = true
      $service_hasrestart = true
      $service_config = '/etc/conf.d/docker'
      $service_config_template = 'docker/etc/conf.d/docker.gentoo.erb'
      $storage_config = undef
      $storage_setup_file = undef
      $pin_upstream_package_source = undef
      $apt_source_pin_level = undef
    }
    default: {
      $manage_epel = false
      $docker_group = $docker_group_default
      $package_key_source = undef
      $package_source_location = undef
      $package_key = undef
      $package_repos = undef
      $package_release = undef
      $purge_packages = undef
      $use_upstream_package_source = true
      $service_overrides_template = undef
      $service_hasstatus  = undef
      $service_hasrestart = undef
      $service_provider = undef
      $package_name = $package_name_default
      $service_name = $service_name_default
      $docker_command = $docker_command_default
      $detach_service_in_init = true
      $repo_opt = undef
      $nowarn_kernel = false
      $service_config = undef
      $storage_config = undef
      $storage_setup_file = undef
      $service_config_template = undef
      $pin_upstream_package_source = undef
      $apt_source_pin_level = undef
    }
  }

  # Special extra packages are required on some OSes.
  # Specifically apparmor is needed for Ubuntu:
  # https://github.com/docker/docker/issues/4734
  $prerequired_packages = $::osfamily ? {
    'Debian' => $::operatingsystem ? {
      'Debian' => ['cgroupfs-mount'],
      'Ubuntu' => ['cgroup-lite', 'apparmor'],
      default  => [],
    },
    'RedHat' => ['device-mapper'],
    default  => [],
  }

}
