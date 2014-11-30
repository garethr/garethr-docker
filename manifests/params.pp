# == Class: docker::params
#
# Default parameter values for the docker module
#
 
class docker::params {
  $version                       = undef
  $ensure                        = present
  $tcp_bind                      = undef
  $socket_bind                   = 'unix:///var/run/docker.sock'
  $socket_group                  = undef
  $use_upstream_package_source   = true
  $service_state                 = running
  $service_enable                = true
  $root_dir                      = undef
  $tmp_dir                       = '/tmp/'
  $dns                           = undef
  $proxy                         = undef
  $no_proxy                      = undef
  $execdriver                    = undef
  $storage_driver                = undef
  $manage_package                = true
  $manage_kernel                 = true
  $ensure_recommended            = 'present'
  $manage_recommended_packages   = true
  $package_name_default          = 'lxc-docker'
  $service_name_default          = 'docker'
  $docker_command_default        = 'docker'
  $install_init_d_script_default = false 
  case $::osfamily {
    'Debian' : {
      case $::operatingsystem {
        'Ubuntu' : {
          $install_init_d_script = true
          $package_name          = $package_name_default
          $service_name          = $service_name_default
          $docker_command        = $docker_command_default
          $kernelpackage         = $::operatingsystemrelease ? {
            '12.04' => [ 'linux-image-generic-lts-trusty', 'linux-headers-generic-lts-trusty' ],
            default => "linux-image-extra-${::kernelrelease}",
          }
        }
        'Debian' : {
          $install_init_d_script = true
          $package_name          = $package_name_default
          $service_name          = $service_name_default
          $docker_command        = $docker_command_default
          $kernelpackage         = 'linux-image-3.16.0-4-amd64'
        }
        default: {
          $package_name   = 'docker.io'
          $service_name   = 'docker.io'
          $docker_command = 'docker.io'
        }
      }
      $package_source_location = 'https://get.docker.io/ubuntu'
      $recommended_packages    = ['bridge-utils']
    }
    'RedHat' : {
      if (versioncmp($::operatingsystemrelease, '7.0') < 0) and $::operatingsystem != 'Amazon' {
        $package_name   = 'docker-io'
      } else {
        $package_name   = 'docker'
      }
      $package_source_location = ''
      $service_name            = $service_name_default
      $docker_command          = $docker_command_default
      $install_init_d_script   = false 
    }
    'Archlinux' : {
      $package_name            = 'docker'
      $package_source_location = ''
      $service_name            = $service_name_default
      $docker_command          = $docker_command_default
      $install_init_d_script   = false 
      exec { 'docker-systemd-reload':
        command     => '/usr/bin/systemctl daemon-reload',
        refreshonly => true,
      }
      }
    default: {
      $package_source_location = ''
      $package_name            = $package_name_default
      $service_name            = $service_name_default
      $docker_command          = $docker_command_default
      $install_init_d_script   = false 
    }
  }

  # Special extra packages are required on some OSes.
  # Specifically apparmor is needed for Ubuntu:
  # https://github.com/docker/docker/issues/4734
  $prerequired_packages = $::operatingsystem ? {
    'Debian' => ['apt-transport-https', 'cgroupfs-mount'],
    'Ubuntu' => ['apt-transport-https', 'cgroup-lite', 'apparmor'],
    default  => '',
  }

}
