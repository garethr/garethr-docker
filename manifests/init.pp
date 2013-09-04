# == Class: docker
#
# Module to install an up-to-date version of Docker from the
# official Apt repository. The use of this repository means, this module works
# only on Debian based distributions.
#
# === Parameters
# [*version*]
#   The package version to install, passed to ensure.
#   Defaults to present.
#
# [*tcp_bind*]
#   The tcp socket to bind to in the format
#   tcp://127.0.0.1:4243
#   Defaults to undefined
#
# [*socket_bind*]
#   The unix socket to bind to. Defaults to
#   unix:///var/run/docker.sock.
#
class docker(
  $version     = $docker::params::version,
  $tcp_bind    = $docker::params::tcp_bind,
  $socket_bind = $docker::params::socket_bind
) inherits docker::params {

  validate_string($version)
  validate_re($::osfamily, '^Debian$', 'This module uses the docker apt repo and only works on Debian systems that support it.')

  class { 'docker::install': } ->
  class { 'docker::config': } ~>
  class { 'docker::service':
    tcp_bind    => $tcp_bind,
    socket_bind => $socket_bind,
  } ->
  Class['docker']
}
