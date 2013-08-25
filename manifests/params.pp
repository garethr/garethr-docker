class docker::params {
  $version     = present
  $tcp_bind    = undef
  $socket_bind = 'unix:///var/run/docker.sock'
}
