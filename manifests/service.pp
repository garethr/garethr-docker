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
  $proxy                = $docker::proxy,
  $no_proxy             = $docker::no_proxy,
  $execdriver           = $docker::execdriver,
){
  case $::osfamily {
    'Debian': {

      $provider = $::operatingsystem ? {
        'Ubuntu' => 'upstart',
        default  => undef,
      }

      service { 'docker':
        ensure     => $service_state,
        enable     => $service_enable,
        hasstatus  => true,
        hasrestart => true,
        provider   => $provider,
      }

      file { '/etc/init/docker.conf':
        ensure  => present,
        force   => true,
        content => template('docker/etc/init/docker.conf.erb'),
        notify  => Service['docker'],
      }
    }
    'RedHat': {
      service { 'docker':
        ensure     => $service_state,
        enable     => $service_enable,
      }

      file { '/etc/sysconfig/docker':
        ensure  => present,
        force   => true,
        content => template('docker/etc/sysconfig/docker.erb'),
        notify  => Service['docker'],
      }
    }
    default: {
      fail('Docker needs a RedHat or Debian based system.')
    }
  }
}
