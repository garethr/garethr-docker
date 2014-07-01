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
  $dns                          = undef
  $proxy                        = undef
  $no_proxy                     = undef
  $execdriver                   = undef
  $storage_driver               = undef
  $manage_package               = true
  $manage_kernel                = true
  $package_name_default         = 'docker.io'
  case $::osfamily {
    'Debian' : {
      case $::operatingsystem {
        'Ubuntu' : {
          case $::operatingsystemrelease {
            '10.04','12.04','13.04','13.10' : { $package_name = 'lxc-docker' }
            default: {
              $package_name = $package_name_default
            }
          }
        }
        default: {
          $package_name = $package_name_default
        }
      }
      $package_source_location = 'https://get.docker.io/ubuntu'
    }
    'RedHat' : {
      $package_source_location = ''
      $package_name = 'docker-io'
    }
    default: {
      $package_source_location = ''
      $package_name = $package_name_default
    }
  }
}
