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
class docker::install {
  include apt
  validate_string($version)
  validate_re($::osfamily, '^Debian$', 'This module uses PPA repos and only works with Debian based distros')

  apt::key { 'docker':
    key        => 'A88D21E9',
    key_source => 'http://get.docker.io/gpg',
  }

  apt::source { 'docker':
    location => 'https://get.docker.io/ubuntu/',
    release  => 'docker',
    repos    => 'main',
    require  => Apt::Key['docker'],
  }

  package { 'lxc-docker':
    ensure  => $docker::version,
    require => Apt::Source['docker'],
  }
}
