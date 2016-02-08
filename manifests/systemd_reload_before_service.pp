# == Class: docker::systemd_reload_before_service
#
# For systems that have systemd
#
# Additional non refreshonly systemd reload, which is required for incompatible changes to the docker service definition.
# the 'docker-systemd-reload' exec cannot be used to protect the service resource as it will introduce a dependency cycle through docker::run of containers.
class docker::systemd_reload_before_service {
  include docker::params
  $service_name = $docker::params::service_name

  validate_string($service_name)

  exec { 'docker-systemd-reload-before-service':
    path    => ['/bin/', '/sbin/', '/usr/bin/', '/usr/sbin/'],
    command => 'systemctl daemon-reload',
    before  => Service[$service_name],
    unless  => 'systemctl status docker'
  }
}
