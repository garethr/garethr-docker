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
# [*log_level*]
#   Set the logging level
#   Defaults to undef: docker defaults to info if no value specified
#   Valid values: debug, info, warn, error, fatal
#
# [*selinux_enabled*]
#   Enable selinux support. Default is false. SELinux does  not  presently
#   support  the  BTRFS storage driver.
#   Valid values: true, false
#
# [*use_upstream_package_source*]
#   Whether or not to use the upstream package source.
#   If you run your own package mirror, you may set this
#   to false.
#
# [*package_source_location*]
#   If you're using an upstream package source, what is it's
#   location. Defaults to https://get.docker.com/ubuntu on Debian
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
# [*dns_search*]
#   Custom dns search domains
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
# [*shell_values*]
#   Array of shell values to pass into init script config files
#
# [*proxy*]
#   Will set the http_proxy and https_proxy env variables in /etc/sysconfig/docker (redhat/centos) or /etc/default/docker (debian)
#
# [*no_proxy*]
#   Will set the no_proxy variable in /etc/sysconfig/docker (redhat/centos) or /etc/default/docker (debian)
#
# [*storage_driver*]
#   Specify a storage driver to use
#   Default is undef: let docker choose the correct one
#   Valid values: aufs, devicemapper, btrfs, overlayfs, vfs
#
# [*dm_basesize*]
#   The size to use when creating the base device, which limits the size of images and containers.
#   Default value is 10G
#
# [*dm_fs*]
#   The filesystem to use for the base image (xfs or ext4)
#   Defaults to ext4
#
# [*dm_mkfsarg*]
#   Specifies extra mkfs arguments to be used when creating the base device.
#
# [*dm_mountopt*]
#   Specifies extra mount options used when mounting the thin devices.
#
# [*dm_blocksize*]
#   A custom blocksize to use for the thin pool.
#   Default blocksize is 64K.
#   Warning: _DO NOT_ change this parameter after the lvm devices have been initialized.
#
# [*dm_loopdatasize*]
#   Specifies the size to use when creating the loopback file for the "data" device which is used for the thin pool
#   Default size is 100G
#
# [*dm_loopmetadatasize*]
#   Specifies the size to use when creating the loopback file for the "metadata" device which is used for the thin pool
#   Default size is 2G
#
# [*dm_datadev*]
#   A custom blockdevice to use for data for the thin pool.
#
# [*dm_metadatadev*]
#   A custom blockdevice to use for metadata for the thin pool.
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
# [*docker_users*]
#   Specify an array of users to add to the docker group
#   Default is empty
#
# [*repo_opt*]
#   Specify a string to pass as repository options (RedHat only)
#
class docker(
  $version                     = $docker::params::version,
  $ensure                      = $docker::params::ensure,
  $prerequired_packages        = $docker::params::prerequired_packages,
  $tcp_bind                    = $docker::params::tcp_bind,
  $socket_bind                 = $docker::params::socket_bind,
  $log_level                   = $docker::params::log_level,
  $selinux_enabled             = $docker::params::selinux_enabled,
  $use_upstream_package_source = $docker::params::use_upstream_package_source,
  $package_source_location     = $docker::params::package_source_location,
  $service_state               = $docker::params::service_state,
  $service_enable              = $docker::params::service_enable,
  $root_dir                    = $docker::params::root_dir,
  $tmp_dir                     = $docker::params::tmp_dir,
  $manage_kernel               = $docker::params::manage_kernel,
  $dns                         = $docker::params::dns,
  $dns_search                  = $docker::params::dns_search,
  $socket_group                = $docker::params::socket_group,
  $extra_parameters            = undef,
  $shell_values                = undef,
  $proxy                       = $docker::params::proxy,
  $no_proxy                    = $docker::params::no_proxy,
  $storage_driver              = $docker::params::storage_driver,
  $dm_basesize                 = $docker::params::dm_basesize,
  $dm_fs                       = $docker::params::dm_fs,
  $dm_mkfsarg                  = $docker::params::dm_mkfsarg,
  $dm_mountopt                 = $docker::params::dm_mountopt,
  $dm_blocksize                = $docker::params::dm_blocksize,
  $dm_loopdatasize             = $docker::params::dm_loopdatasize,
  $dm_loopmetadatasize         = $docker::params::dm_loopmetadatasize,
  $dm_datadev                  = $docker::params::dm_datadev,
  $dm_metadatadev              = $docker::params::dm_metadatadev,
  $execdriver                  = $docker::params::execdriver,
  $manage_package              = $docker::params::manage_package,
  $manage_epel                 = $docker::params::manage_epel,
  $package_name                = $docker::params::package_name,
  $service_name                = $docker::params::service_name,
  $docker_command              = $docker::params::docker_command,
  $docker_users                = [],
  $repo_opt                    = $docker::params::repo_opt,
  $nowarn_kernel               = $docker::params::nowarn_kernel,
) inherits docker::params {

  validate_string($version)
  validate_re($::osfamily, '^(Debian|RedHat|Archlinux)$', 'This module only works on Debian and Red Hat based systems.')
  validate_bool($manage_kernel)
  validate_bool($manage_package)
  validate_array($docker_users)

  if $log_level {
    validate_re($log_level, '^(debug|info|warn|error|fatal)$', 'log_level must be one of debug, info, warn, error or fatal')
  }

  if $selinux_enabled {
    validate_re($selinux_enabled, '^(true|false)$', 'selinux_enabled must be true or false')
  }

  if $storage_driver {
    validate_re($storage_driver, '^(aufs|devicemapper|btrfs|overlay|vfs)$', 'Valid values for storage_driver are aufs, devicemapper, btrfs, overlayfs, vfs.' )
  }

  if $dm_fs {
    validate_re($dm_fs, '^(ext4|xfs)$', 'Only ext4 and xfs are supported currently for dm_fs.')
  }

  if ($dm_loopdatasize or $dm_loopmetadatasize) and ($dm_datadev or $dm_metadatadev) {
    fail('You should provide parameters only for loop lvm or direct lvm, not both.')
  }

  if ($dm_datadev and !$dm_metadatadev) or (!$dm_datadev and $dm_metadatadev) {
    fail('You need to provide both $dm_datadev and $dm_metadatadev parameters for direct lvm.')
  }

  class { 'docker::install': } ->
  class { 'docker::config': } ~>
  class { 'docker::service': }
  contain 'docker::install'
  contain 'docker::config'
  contain 'docker::service'

  # Only bother trying extra docker stuff after docker has been installed,
  # and is running.
  Class['docker'] -> Docker::Registry <||> -> Docker::Run <||>
  Class['docker'] -> Docker::Image <||>

}
