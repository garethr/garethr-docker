# == Class: docker::params
#
# Defaut parameter values for the docker module
#
class docker::params {
  $version                      = undef
  $ensure                       = present
  $tcp_bind                     = undef
  $socket_bind                  = 'unix:///var/run/docker.sock'
  $use_upstream_package_source  = true
  $service_state                = running
  $service_enable               = true
  $root_dir                     = undef
  $dns                          = undef
  case $::osfamily {
    'Debian': { $package_source_location = 'https://get.docker.io/ubuntu' }
    default:  { $package_source_location = '' }
  }
  $proxy                        = undef
  $no_proxy                     = undef
  $execdriver                   = undef
}
