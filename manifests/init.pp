# == Class: docker
#
# Module to install an up-to-date version of Docker from package.
#
# === Parameters
#
# [*version*]
#   The package version to install, used to set the package name.
#   Defaults to undefined
#
# [*ensure*]
#   Passed to the docker package.
#   Defaults to present
#
# [*prerequired_packages*]
#   An array of additional packages that need to be installed to support
#   docker. Defaults change depending on the operating system.
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
#
# [*package_source_location*]
#   If you're using an upstream package source, what is it's
#   location. Defaults to https://get.docker.io/ubuntu on Debian
#
# [*service_state*]
#   Whether you want to docker daemon to start up
#   Defaults to running
#
# [*service_enable*]
#   Whether you want to docker daemon to start up at boot
#   Defaults to true
#
# [*root_dir*]
#   Custom root directory for containers
#   Defaults to undefined
#
# [*manage_kernel*]
#   Attempt to install the correct Kernel required by docker
#   Defaults to true
#
# [*dns*]
#   Custom dns server address
#   Defaults to undefined
#
# [*socket_group*]
#   Group ownership of the unix control socket.
#   Defaults to undefined
#
# [*extra_parameters*]
#   Any extra parameters that should be passed to the docker daemon.
#   Defaults to undefined
#
# [*proxy*]
#   Will set the http_proxy and https_proxy env variables in /etc/sysconfig/docker (redhat/centos) or /etc/default/docker (debian)
#
# [*no_proxy*]
#   Will set the no_proxy variable in /etc/sysconfig/docker (redhat/centos) or /etc/default/docker (debian)
#
# [*manage_package*]
#   Won't install or define the docker package, useful if you want to use your own package
#   Defaults to true
#
# [*package_name*]
#   Specify custom package name
#   Default is set on a per system basis in docker::params
#
# [*service_name*]
#   Specify custom service name
#   Default is set on a per system basis in docker::params
#
# [*docker_command*]
#   Specify a custom docker command name
#   Default is set on a per system basis in docker::params
#
class docker(
  $version                     = $docker::params::version,
  $ensure                      = $docker::params::ensure,
  $prerequired_packages        = $docker::params::prerequired_packages,
  $tcp_bind                    = $docker::params::tcp_bind,
  $socket_bind                 = $docker::params::socket_bind,
  $use_upstream_package_source = $docker::params::use_upstream_package_source,
  $package_source_location     = $docker::params::package_source_location,
  $service_state               = $docker::params::service_state,
  $service_enable              = $docker::params::service_enable,
  $root_dir                    = $docker::params::root_dir,
  $tmp_dir                     = $docker::params::tmp_dir,
  $manage_kernel               = $docker::params::manage_kernel,
  $dns                         = $docker::params::dns,
  $socket_group                = $docker::params::socket_group,
  $extra_parameters            = undef,
  $proxy                       = $docker::params::proxy,
  $no_proxy                    = $docker::params::no_proxy,
  $storage_driver              = $docker::params::storage_driver,
  $execdriver                  = $docker::params::execdriver,
  $manage_package              = $docker::params::manage_package,
  $package_name                = $docker::params::package_name,
  $service_name                = $docker::params::service_name,
  $docker_command              = $docker::params::docker_command,
) inherits docker::params {

  validate_string($version)
  validate_re($::osfamily, '^(Debian|RedHat|Archlinux)$', 'This module only works on Debian and Red Hat based systems.')
  validate_bool($manage_kernel)
  validate_bool($manage_package)

  class { 'docker::install': } ->
  class { 'docker::config': } ~>
  class { 'docker::service': } ->
  Class['docker']
}
