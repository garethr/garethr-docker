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
# [*extra_parameters*]
#   Plain additional parameters to pass to the docker daemon
#
class docker::service (
  $tcp_bind             = $docker::tcp_bind,
  $socket_bind          = $docker::socket_bind,
  $service_state        = $docker::service_state,
  $service_enable       = $docker::service_enable,
  $root_dir             = $docker::root_dir,
  $extra_parameters     = $docker::extra_parameters,
){
  $provider = $::operatingsystem ? {
    'Ubuntu' => 'upstart',
    default  => undef,
  }

  case $::osfamily {
    'Debian': {
      $hasstatus     = true
      $hasrestart    = true
      $init_file     =  '/etc/init/docker.conf'
      $init_template = 'docker/etc/init/docker.conf.erb'
    }
    'RedHat': {
      $hasstatus     = undef
      $hasrestart    = undef
      $init_file     = '/etc/sysconfig/docker'
      $init_template = 'docker/etc/sysconfig/docker.erb'
    }
    default: {
      fail('Docker needs a RedHat or Debian based system.')
    }
  }

  file { $init_file:
    ensure  => present,
    force   => true,
    content => template($init_template),
    notify  => Service['docker'],
  }

  service { 'docker':
    ensure     => $service_state,
    enable     => $service_enable,
    hasstatus  => $hasstatus,
    hasrestart => $hasrestart,
    provider   => $provider,
  }

}
