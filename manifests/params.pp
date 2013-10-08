class docker::params {
  $version        = present
  $tcp_bind       = undef
  $network_bridge = undef
  $socket_bind    = 'unix:///var/run/docker.sock'
}
