# == Class: docker::systemd_reload
#
# For systems that have systemd
#
class docker::systemd_reload {
  exec { 'docker-systemd-reload':
    command     => '/usr/bin/systemctl daemon-reload',
    refreshonly => true,
  }
}