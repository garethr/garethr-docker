# == Class: docker::service
#
# Class to manage the docker service daemon
#
# === Parameters
# [*tcp_bind*]
#   Which tcp port, if any, to bind the docker service to.
#
# [*socket_bind*]
#   Which local unix socket to bind the docker service to.
#
# [*root_dir*]
#   Specify a non-standard root directory for docker.
#
class docker::service (
  $tcp_bind             = $docker::tcp_bind,
  $socket_bind          = $docker::socket_bind,
  $service_state        = $docker::service_state,
  $root_dir             = $docker::root_dir,
){
  service { 'docker':
    ensure     => $service_state,
    enable     => true,
    hasstatus  => true,
    hasrestart => true,
    provider   => upstart,
  }

  file { '/etc/init/docker.conf':
    ensure  => present,
    force   => true,
    content => template('docker/etc/init/docker.conf.erb'),
    notify  => Service['docker'],
  }
}
