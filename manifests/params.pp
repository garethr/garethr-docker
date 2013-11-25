class docker::params {
  $version                 = undef
  $ensure                  = present
  $tcp_bind                = undef
  $socket_bind             = 'unix:///var/run/docker.sock'
  $use_upstream_apt_source = true
  $service_state           = running
}
