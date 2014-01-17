# == Class: docker
#
# Module to install an up-to-date version of Docker from package.
#
# === Parameters
# [*version*]
#   The package version to install, passed to ensure.
#   Defaults to present
#
# [*tcp_bind*]
#   The tcp socket to bind to in the format
#   tcp://127.0.0.1:4243
#   Defaults to undefined
#
# [*socket_bind*]
#   The unix socket to bind to. Defaults to
#   unix:///var/run/docker.sock.
#
# [*use_upstream_package_source*]
#   Whether or not to use the upstream package source.
#   If you run your own package mirror, you may set this
#   to false.
# [*package_source_location*]
#   If you're using an upstream package source, what is it's
#   location. Defaults to https://get.docker.io/ubuntu on Debian
# [*manage_kernel*]
#   Attempt to install the correct Kernel required by docker
#   Defaults to true
# [*extra_parameters*]
#   Any extra parameters that should be passed to the docker daemon.
#   Defaults to undefined
#
class docker(
  $version                     = $docker::params::version,
  $ensure                      = $docker::params::ensure,
  $tcp_bind                    = $docker::params::tcp_bind,
  $socket_bind                 = $docker::params::socket_bind,
  $use_upstream_package_source = $docker::params::use_upstream_package_source,
  $package_source_location     = $docker::params::package_source_location,
  $service_state               = $docker::params::service_state,
  $root_dir                    = $docker::params::root_dir,
  $manage_kernel               = true,
  $dns                         = $docker::params::dns,
  $extra_parameters            = undef,
) inherits docker::params {

  validate_string($version)
  validate_re($::osfamily, '^(Debian|RedHat)$', 'This module only works on Debian and Red Hat based systems.')
  validate_bool($manage_kernel)

  class { 'docker::install': } ->
  class { 'docker::config': } ~>
  class { 'docker::service': } ->
  Class['docker']
}
