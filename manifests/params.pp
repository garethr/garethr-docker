# == Class: docker::paramrs
#
# Defaut parameter values for the docker module
#
class docker::params {
  $version                 = undef
  $ensure                  = present
  $tcp_bind                = undef
  $socket_bind             = 'unix:///var/run/docker.sock'
  $use_upstream_apt_source = true
  $service_state           = running
  $root_dir                = undef
  $apt_source_location     = 'https://get.docker.io/ubuntu'
  $dns			   = undef
}
