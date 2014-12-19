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
# [*socket_group*]
#   Which local unix socket to bind the docker service to.
#
# [*root_dir*]
#   Specify a non-standard root directory for docker.
#
# [*extra_parameters*]
#   Plain additional parameters to pass to the docker daemon
#
class docker::service (
  $docker_command       = $docker::docker_command,
  $service_name         = $docker::service_name,
  $tcp_bind             = $docker::tcp_bind,
  $socket_bind          = $docker::socket_bind,
  $socket_group         = $docker::socket_group,
  $dns                  = $docker::dns,
  $dns_search           = $docker::dns_search,
  $service_state        = $docker::service_state,
  $service_enable       = $docker::service_enable,
  $root_dir             = $docker::root_dir,
  $extra_parameters     = $docker::extra_parameters,
  $proxy                = $docker::proxy,
  $no_proxy             = $docker::no_proxy,
  $execdriver           = $docker::execdriver,
  $storage_driver       = $docker::storage_driver,
  $tmp_dir              = $docker::tmp_dir,
) {
  $dns_array = any2array($dns)
  $dns_search_array = any2array($dns_search)
  $extra_parameters_array = any2array($extra_parameters)

  case $::osfamily {
    'Debian': {
      $hasstatus     = true
      $hasrestart    = false

      file { '/etc/init.d/docker':
          ensure => 'link',
          target => '/lib/init/upstart-job',
          force  => true,
          notify => Service['docker'],
      }

      file { "/etc/default/${service_name}":
        ensure  => present,
        force   => true,
        content => template('docker/etc/default/docker.erb'),
        notify  => Service['docker'],
      }
    }
    'RedHat': {
      if ($::operatingsystem == 'Fedora') or (versioncmp($::operatingsystemrelease, '7.0') >= 0) {
        $template = 'docker.rhel7.erb'
      } else {
        $template = 'docker.erb'
      }
      $hasstatus     = undef
      $hasrestart    = undef

      file { '/etc/sysconfig/docker':
        ensure  => present,
        force   => true,
        content => template("docker/etc/sysconfig/${template}"),
        notify  => Service['docker'],
      }
    }
    'Archlinux': {
      $hasstatus  = true
      $hasrestart = true

      file {
        '/etc/systemd/system/docker.service.d':
          ensure => directory;

        '/etc/systemd/system/docker.service.d/service-overrides.conf':
          ensure => present,
          source => 'puppet:///modules/docker/service-overrides-archlinux.conf',
          notify => Exec['docker-systemd-reload'];

        '/etc/conf.d/docker':
          ensure  => present,
          force   => true,
          content => template('docker/etc/conf.d/docker.erb'),
          notify  => Service['docker'];
      }
    }
    default: {
      fail('Docker needs a Debian, RedHat or Archlinux based system.')
    }
  }

  $provider = $::operatingsystem ? {
    'Ubuntu' => 'upstart',
    default  => undef,
  }

  service { 'docker':
    ensure     => $service_state,
    name       => $service_name,
    enable     => $service_enable,
    hasstatus  => $hasstatus,
    hasrestart => $hasrestart,
    provider   => $provider,
  }

}
