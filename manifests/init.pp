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
class docker(
  $version = $docker::params::version,
) inherits docker::params {

  validate_string($version)
  validate_re($::operatingsystem, '^Ubuntu$', 'This module works currently only with Ubuntu based distributions.')

  class { 'docker::install': } ->
  class { 'docker::config': } ~>
  class { 'docker::service': } ->
  Class['docker']
}
