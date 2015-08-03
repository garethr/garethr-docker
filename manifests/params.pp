# == Class: docker::params
#
# Default parameter values for the docker module
#
class docker::params {
  $version                      = undef
  $ensure                       = present
  $tcp_bind                     = undef
  $socket_bind                  = 'unix:///var/run/docker.sock'
  $log_level                    = undef
  $selinux_enabled              = undef
  $socket_group                 = undef
  $service_state                = running
  $service_enable               = true
  $root_dir                     = undef
  $tmp_dir                      = '/tmp/'
  $dns                          = undef
  $dns_search                   = undef
  $proxy                        = undef
  $no_proxy                     = undef
  $execdriver                   = undef
  $storage_driver               = undef
  $dm_basesize                  = undef
  $dm_fs                        = undef
  $dm_mkfsarg                   = undef
  $dm_mountopt                  = undef
  $dm_blocksize                 = undef
  $dm_loopdatasize              = undef
  $dm_loopmetadatasize          = undef
  $dm_datadev                   = undef
  $dm_metadatadev               = undef
  $manage_package               = true
  $manage_kernel                = true
  $manage_epel                  = true
  $package_name_default         = 'lxc-docker'
  $service_name_default         = 'docker'
  $docker_command_default       = 'docker'
  $docker_group_default         = 'docker'
  case $::osfamily {
    'Debian' : {
      case $::operatingsystem {
        'Ubuntu' : {
          $package_name   = $package_name_default
          $service_name   = $service_name_default
          $docker_command = $docker_command_default
        }
        default: {
          $package_name   = 'docker.io'
          $service_name   = 'docker.io'
          $docker_command = 'docker.io'
        }
      }
      $docker_group = $docker_group_default
      $package_source_location     = 'https://get.docker.com/ubuntu'
      $use_upstream_package_source = true
      $detach_service_in_init = true
      $repo_opt = undef
      $nowarn_kernel = false
    }
    'RedHat' : {
      if $::operatingsystem == 'Fedora' {
        $package_name   = 'docker-io'
        $use_upstream_package_source = false
      } elsif (versioncmp($::operatingsystemrelease, '7.0') < 0) and $::operatingsystem != 'Amazon' {
        $package_name   = 'docker-io'
        $use_upstream_package_source = true
      } else {
        $package_name   = 'docker'
        $use_upstream_package_source = false
      }
      $package_source_location = ''
      $service_name   = $service_name_default
      $docker_command = $docker_command_default
      if versioncmp($::operatingsystemrelease, '7.0') < 0 {
        $detach_service_in_init = true
        if $::operatingsystem == 'OracleLinux' {
          $docker_group = 'dockerroot'
        } else {
          $docker_group = $docker_group_default
        }
      } else {
        $detach_service_in_init = false
        $docker_group = 'dockerroot'
        include docker::systemd_reload
      }

      # repo_opt to specify install_options for docker package
      if (versioncmp($::operatingsystemmajrelease, '7') == 0) {
        if $::operatingsystem == 'RedHat' {
          $repo_opt = '--enablerepo=rhel7-extras'
        } elsif $::operatingsystem == 'OracleLinux' {
          $repo_opt = '--enablerepo=ol7_addons'
        } elsif $::operatingsystem == 'Scientific' {
          $repo_opt = '--enablerepo=sl-extras'
        } else {
          $repo_opt = undef
        }
      } elsif (versioncmp($::operatingsystemrelease, '7.0') < 0 and $::operatingsystem == 'OracleLinux') {
          # FIXME is 'public_ol6_addons' available on all OL6 installs?
          $repo_opt = '--enablerepo=public_ol6_addons,public_ol6_latest'
      } else {
        $repo_opt = undef
      }
      if $::kernelversion == '2.6.32' { $nowarn_kernel = true }
      else { $nowarn_kernel = false }
    }
    'Archlinux' : {
      $docker_group = $docker_group_default
      $package_source_location     = ''
      $use_upstream_package_source = false
      $package_name   = 'docker'
      $service_name   = $service_name_default
      $docker_command = $docker_command_default
      $detach_service_in_init = false
      include docker::systemd_reload
      $repo_opt = undef
      $nowarn_kernel = false
    }
    default: {
      $docker_group = $docker_group_default
      $package_source_location     = ''
      $use_upstream_package_source = true
      $package_name   = $package_name_default
      $service_name   = $service_name_default
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
      'Debian' => ['apt-transport-https', 'cgroupfs-mount'],
      'Ubuntu' => ['apt-transport-https', 'cgroup-lite', 'apparmor'],
      default  => [],
    },
    'RedHat' => ['device-mapper'],
    default  => [],
  }

}
