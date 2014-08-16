# == Class: docker::params
#
# Defaut parameter values for the docker module
#
class docker::params {
  $version                      = undef
  $ensure                       = present
  $tcp_bind                     = undef
  $socket_bind                  = 'unix:///var/run/docker.sock'
  $socket_group                 = undef
  $use_upstream_package_source  = true
  $service_state                = running
  $service_enable               = true
  $root_dir                     = undef
  $tmp_dir                      = '/tmp/'
  $dns                          = undef
  $proxy                        = undef
  $no_proxy                     = undef
  $execdriver                   = undef
  $storage_driver               = undef
  $manage_package               = true
  $manage_kernel                = true
  $package_name_default         = 'lxc-docker'
  $service_name_default         = 'docker'
  $docker_command_default       = 'docker'
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
      $package_source_location = 'https://get.docker.io/ubuntu'
    }
    'RedHat' : {
      if (versioncmp($::operatingsystemrelease, '7.0') < 0) {
        $package_name   = 'docker-io'
      } else {
        $package_name   = 'docker'
      }
      $package_source_location = ''
      $service_name   = $service_name_default
      $docker_command = $docker_command_default
    }
    default: {
      $package_source_location = ''
      $package_name   = $package_name_default
      $service_name   = $service_name_default
      $docker_command = $docker_command_default
    }
  }
}
