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
class docker::install (
  $tcp_bind = undef,
  $unix_socket = 'unix:///var/run/docker.sock',
){
  include apt
  validate_string($version)
  validate_re($::osfamily, '^Debian$', 'This module uses the docker apt repo and only works on Debian systems that support it.')

  apt::source { 'docker':
    location          => 'https://get.docker.io/docker',
    release           => 'ubuntu',
    repos             => 'main',
    required_packages => 'debian-keyring debian-archive-keyring',
    key               => 'A88D21E9',
    key_source        => 'http://get.docker.io/gpg',
    pin               => '10',
    include_src       => false,
  }
    
  package { 'lxc-docker':
    ensure  => $docker::version,
    require => Apt::Source['docker'],
  }

  file { '/etc/init/docker':
    content => template('docker/etc/init/docker.conf.erb')
  }
}
