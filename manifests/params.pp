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
  $package_name_default              = 'docker-engine'
  $service_name_default              = 'docker'
  $docker_command_default            = 'docker'
  $docker_group_default              = 'docker'
  $daemon_subcommand                 = 'daemon'
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
  $compose_version                   = '1.7.0'

  case $::osfamily {
    'Debian' : {
      case $::operatingsystem {
        'Ubuntu' : {
          $package_release = "ubuntu-${::lsbdistcodename}"
          if (versioncmp($::operatingsystemrelease, '15.04') >= 0) {
            $service_provider        = 'systemd'
            $storage_config          = '/etc/default/docker-storage'
            $service_config_template = 'docker/etc/sysconfig/docker.systemd.erb'
            $service_hasstatus       = true
            $service_hasrestart      = true
            include docker::systemd_reload
          } else {
            $service_config_template = 'docker/etc/default/docker.erb'
            $service_provider        = 'upstart'
            $service_hasstatus       = true
            $service_hasrestart      = false
          }
        }
        default: {
          $package_release = "debian-${::lsbdistcodename}"
          if (versioncmp($::operatingsystemmajrelease, '8') >= 0) {
            $service_provider           = 'systemd'
            $storage_config             = '/etc/default/docker-storage'
            $service_config_template    = 'docker/etc/sysconfig/docker.systemd.erb'
            $service_overrides_template = 'docker/etc/systemd/system/docker.service.d/service-overrides-debian.conf.erb'
            $service_hasstatus       = true
            $service_hasrestart      = true
            include docker::systemd_reload
          } else {
            $service_config_template = 'docker/etc/default/docker.erb'
          }
        }
      }

      $manage_epel = false
      $package_name = $package_name_default
      $service_name = $service_name_default
      $docker_command = $docker_command_default
      $docker_group = $docker_group_default
      $package_repos = 'main'
      $use_upstream_package_source = true
      $repo_opt = undef
      $nowarn_kernel = false

      $package_cs_source_location = 'http://packages.docker.com/1.9/apt/repo'
      $package_cs_key_source = 'http://packages.docker.com/1.9/apt/gpg'
      $package_cs_key = '0xee6d536cf7dc86e2d7d56f59a178ac6c6238f52e'
      $package_source_location = 'http://apt.dockerproject.org/repo'
      $package_key_source = 'http://apt.dockerproject.org/gpg'
      $package_key = '58118E89F3A912897C070ADBF76221572C52609D'

      if ($::operatingsystem == 'Debian' and versioncmp($::operatingsystemmajrelease, '8') >= 0) or ($::operatingsystem == 'Ubuntu' and versioncmp($::operatingsystemrelease, '15.04') >= 0) {
        $detach_service_in_init = false
      } else {
        $detach_service_in_init = true
      }

    }
    'RedHat' : {
      $service_config = '/etc/sysconfig/docker'
      $storage_config = '/etc/sysconfig/docker-storage'
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
        $package_name = 'docker-io'
        $use_upstream_package_source = false
        $manage_epel = true
      } elsif $::operatingsystem == 'Amazon' {
        $package_name = 'docker'
        $use_upstream_package_source = false
        $manage_epel = false
      } else {
        $package_name = $package_name_default
        $use_upstream_package_source = true
        $manage_epel = false
      }
      $package_key_source = 'https://yum.dockerproject.org/gpg'
      if $::operatingsystem == 'Fedora' {
        $package_source_location = "https://yum.dockerproject.org/repo/main/fedora/${::operatingsystemmajrelease}"
      } else {
        $package_source_location = "https://yum.dockerproject.org/repo/main/centos/${::operatingsystemmajrelease}"
      }
      $package_cs_source_location = "https://packages.docker.com/1.9/yum/repo/main/centos/${::operatingsystemmajrelease}"
      $package_cs_key_source = 'https://packages.docker.com/1.9/yum/gpg'
      $package_key = undef
      $package_cs_ke = undef
      $package_repos = undef
      $package_release = undef
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
      $package_key_source = undef
      $package_source_location = undef
      $package_key = undef
      $package_repos = undef
      $package_release = undef
      $use_upstream_package_source = false
      $package_name = 'docker'
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
    }
    'Gentoo' : {
      $manage_epel = false
      $docker_group = $docker_group_default
      $package_key_source = undef
      $package_source_location = undef
      $package_key = undef
      $package_repos = undef
      $package_release = undef
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
    }
    default: {
      $manage_epel = false
      $docker_group = $docker_group_default
      $package_key_source = undef
      $package_source_location = undef
      $package_key = undef
      $package_repos = undef
      $package_release = undef
      $use_upstream_package_source = true
      $service_hasstatus  = undef
      $service_hasrestart = undef
      $package_name = $package_name_default
      $service_name = $service_name_default
      $docker_command = $docker_command_default
      $detach_service_in_init = true
      $repo_opt = undef
      $nowarn_kernel = false
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
