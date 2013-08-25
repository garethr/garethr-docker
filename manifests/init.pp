# == Class: docker
#
# Module to install an up-to-date version of Docker from the
# official PPA. The use of the PPA means this only works
# on Ubuntu.
#
# === Parameters
# [*version*]
#   The package version to install, passed to ensure.
#   Defaults to present.
#
# [*tcp_bind*]
# The tcp socket to bind to in the format like 
# tcp://127.0.0.1:4243. 
# Defaults to undefined.
#
# [*socket_bind*]
# The unix socket to bind to. Defaults to 
# unix:///var/run/docker.sock.
#
class docker(
  $version     = $docker::params::version,
  $tcp_bind    = $docker::params::tcp_bind,
  $socket_bind = $docker::params::socket_bind
) inherits docker::params {

  validate_string($version)
  validate_re($::osfamily, '^Debian$', 'This module uses PPA repos and only works with Debian based distros')

  class { 'docker::install': 
    tcp_bind    => $tcp_bind,
    socket_bind => $socket_bind,
  } ->
  class { 'docker::config': } ~>
  class { 'docker::service': } ->
  Class['docker']
}
