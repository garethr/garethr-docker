# == Class: docker_old::systemd_reload
#
# For systems that have systemd
#
class docker_old::systemd_reload {
  exec { 'docker-systemd-reload':
    path        => ['/bin/', '/sbin/', '/usr/bin/', '/usr/sbin/'],
    command     => 'systemctl daemon-reload',
    refreshonly => true,
  }
}
