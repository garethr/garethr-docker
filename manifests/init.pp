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
# [*docker_cs*]
#   Whether or not to use the CS (Commercial Support) Docker packages.
#   Defaults to false.
#
# [*tcp_bind*]
#   The tcp socket to bind to in the format
#   tcp://127.0.0.1:4243
#   Defaults to undefined
#
# [*tls_enable*]
#   Enable TLS.
#   Defaults to false
#
# [*tls_verify*]
#  Use TLS and verify the remote
#  Defaults to true
#
# [*tls_cacert*]
#   Path to TLS CA certificate
#   Defaults to '/etc/docker/ca.pem'
#
# [*tls_cert*]
#   Path to TLS certificate file
#   Defaults to '/etc/docker/cert.pem'
#
# [*tls_key*]
#   Path to TLS key file
#   Defaults to '/etc/docker/cert.key'
#
# [*ip_forward*]
#   Enables IP forwarding on the Docker host.
#   The default is true.
#
# [*iptables*]
#   Enable Docker's addition of iptables rules.
#   Default is true.
#
# [*ip_masq*]
#   Enable IP masquerading for bridge's IP range.
#   The default is true.
#
# [*bip*]
#   Specify docker's network bridge IP, in CIDR notation.
#   Defaults to undefined.
#
# [*mtu*]
#   Docker network MTU.
#   Defaults to undefined.
#
# [*bridge*]
#   Attach containers to a pre-existing network bridge
#   use 'none' to disable container networking
#   Defaults to undefined.
#
# [*fixed_cidr*]
#   IPv4 subnet for fixed IPs
#   10.20.0.0/16
#   Defaults to undefined
#
# [*default_gateway*]
#   IPv4 address of the container default gateway;
#   this address must be part of the bridge subnet
#   (which is defined by bridge)
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
# [*log_driver*]
#   Set the log driver.
#   Defaults to undef.
#   Docker default is json-file.
#   Valid values: none, json-file, syslog, journald, gelf, fluentd
#   Valid values description:
#     none     : Disables any logging for the container.
#                docker logs won't be available with this driver.
#     json-file: Default logging driver for Docker.
#                Writes JSON messages to file.
#     syslog   : Syslog logging driver for Docker.
#                Writes log messages to syslog.
#     journald : Journald logging driver for Docker.
#                Writes log messages to journald.
#     gelf     : Graylog Extended Log Format (GELF) logging driver for Docker.
#                Writes log messages to a GELF endpoint: Graylog or Logstash.
#     fluentd  : Fluentd logging driver for Docker.
#                Writes log messages to fluentd (forward input).
#
# [*log_opt*]
#   Set the log driver specific options
#   Defaults to undef
#   Valid values per log driver:
#     none     : undef
#     json-file:
#                max-size=[0-9+][k|m|g]
#                max-file=[0-9+]
#     syslog   :
#                syslog-address=[tcp|udp]://host:port
#                syslog-address=unix://path
#                syslog-facility=daemon|kern|user|mail|auth|
#                                syslog|lpr|news|uucp|cron|
#                                authpriv|ftp|
#                                local0|local1|local2|local3|
#                                local4|local5|local6|local7
#                syslog-tag="some_tag"
#     journald : undef
#     gelf     :
#                gelf-address=udp://host:port
#                gelf-tag="some_tag"
#     fluentd  :
#                fluentd-address=host:port
#                fluentd-tag={{.ID}} - short container id (12 characters)|
#                            {{.FullID}} - full container id
#                            {{.Name}} - container name
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
#   location. Defaults to http://get.docker.com/ubuntu on Debian
#
# [*service_state*]
#   Whether you want to docker daemon to start up
#   Defaults to running
#
# [*service_enable*]
#   Whether you want to docker daemon to start up at boot
#   Defaults to true
#
# [*manage_service*]
#   Specify whether the service should be managed.
#   Valid values are 'true', 'false'.
#   Defaults to 'true'.
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
#   Valid values: aufs, devicemapper, btrfs, overlay, vfs, zfs
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
#   (deprecated - dm_thinpooldev should be used going forward)
#   A custom blockdevice to use for data for the thin pool.
#
# [*dm_metadatadev*]
#   (deprecated - dm_thinpooldev should be used going forward)
#   A custom blockdevice to use for metadata for the thin pool.
#
# [*dm_thinpooldev*]
#   Specifies a custom block storage device to use for the thin pool.
#
# [*dm_use_deferred_removal*]
#   Enables use of deferred device removal if libdm and the kernel driver support the mechanism.
#
# [*dm_use_deferred_deletion*]
#    Enables use of deferred device deletion if libdm and the kernel driver support the mechanism.
#
# [*dm_blkdiscard*]
#   Enables or disables the use of blkdiscard when removing devicemapper devices.
#   Defaults to false
#
# [*dm_override_udev_sync_check*]
#   By default, the devicemapper backend attempts to synchronize with the udev device manager for the Linux kernel. This option allows disabling that synchronization, to continue even though the configuration may be buggy.
#   Defaults to true
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
# [*daemon_subcommand*]
#  Specify a subcommand/flag for running docker as daemon
#  Default is set on a per system basis in docker::params
#
# [*docker_users*]
#   Specify an array of users to add to the docker group
#   Default is empty
#
# [*repo_opt*]
#   Specify a string to pass as repository options (RedHat only)
#
# [*storage_devs*]
#   A quoted, space-separated list of devices to be used.
#
# [*storage_vg*]
#   The volume group to use for docker storage.
#
# [*storage_root_size*]
#   The size to which the root filesystem should be grown.
#
# [*storage_data_size*]
#   The desired size for the docker data LV
#
# [*storage_min_data_size*]
#   The minimum size of data volume otherwise pool creation fails
#
# [*storage_chunk_size*]
#   Controls the chunk size/block size of thin pool.
#
# [*storage_growpart*]
#   Enable resizing partition table backing root volume group.
#
# [*storage_auto_extend_pool*]
#   Enable/disable automatic pool extension using lvm
#
# [*storage_pool_autoextend_threshold*]
#   Auto pool extension threshold (in % of pool size)
#
# [*storage_pool_autoextend_percent*]
#   Extend the pool by specified percentage when threshold is hit.
#
class docker(
  $version                           = $docker::params::version,
  $ensure                            = $docker::params::ensure,
  $prerequired_packages              = $docker::params::prerequired_packages,
  $docker_cs                         = $docker::params::docker_cs,
  $tcp_bind                          = $docker::params::tcp_bind,
  $tls_enable                        = $docker::params::tls_enable,
  $tls_verify                        = $docker::params::tls_verify,
  $tls_cacert                        = $docker::params::tls_cacert,
  $tls_cert                          = $docker::params::tls_cert,
  $tls_key                           = $docker::params::tls_key,
  $ip_forward                        = $docker::params::ip_forward,
  $ip_masq                           = $docker::params::ip_masq,
  $bip                               = $docker::params::bip,
  $mtu                               = $docker::params::mtu,
  $iptables                          = $docker::params::iptables,
  $socket_bind                       = $docker::params::socket_bind,
  $fixed_cidr                        = $docker::params::fixed_cidr,
  $bridge                            = $docker::params::bridge,
  $default_gateway                   = $docker::params::default_gateway,
  $log_level                         = $docker::params::log_level,
  $log_driver                        = $docker::params::log_driver,
  $log_opt                           = $docker::params::log_opt,
  $selinux_enabled                   = $docker::params::selinux_enabled,
  $use_upstream_package_source       = $docker::params::use_upstream_package_source,
  $package_source_location           = $docker::params::package_source_location,
  $package_release                   = $docker::params::package_release,
  $package_repos                     = $docker::params::package_repos,
  $package_key                       = $docker::params::package_key,
  $package_key_source                = $docker::params::package_key_source,
  $service_state                     = $docker::params::service_state,
  $service_enable                    = $docker::params::service_enable,
  $manage_service                    = $docker::params::manage_service,
  $root_dir                          = $docker::params::root_dir,
  $tmp_dir                           = $docker::params::tmp_dir,
  $manage_kernel                     = $docker::params::manage_kernel,
  $dns                               = $docker::params::dns,
  $dns_search                        = $docker::params::dns_search,
  $socket_group                      = $docker::params::socket_group,
  $labels                            = $docker::params::labels,
  $extra_parameters                  = undef,
  $shell_values                      = undef,
  $proxy                             = $docker::params::proxy,
  $no_proxy                          = $docker::params::no_proxy,
  $storage_driver                    = $docker::params::storage_driver,
  $dm_basesize                       = $docker::params::dm_basesize,
  $dm_fs                             = $docker::params::dm_fs,
  $dm_mkfsarg                        = $docker::params::dm_mkfsarg,
  $dm_mountopt                       = $docker::params::dm_mountopt,
  $dm_blocksize                      = $docker::params::dm_blocksize,
  $dm_loopdatasize                   = $docker::params::dm_loopdatasize,
  $dm_loopmetadatasize               = $docker::params::dm_loopmetadatasize,
  $dm_datadev                        = $docker::params::dm_datadev,
  $dm_metadatadev                    = $docker::params::dm_metadatadev,
  $dm_thinpooldev                    = $docker::params::dm_thinpooldev,
  $dm_use_deferred_removal           = $docker::params::dm_use_deferred_removal,
  $dm_use_deferred_deletion          = $docker::params::dm_use_deferred_deletion,
  $dm_blkdiscard                     = $docker::params::dm_blkdiscard,
  $dm_override_udev_sync_check       = $docker::params::dm_override_udev_sync_check,
  $execdriver                        = $docker::params::execdriver,
  $manage_package                    = $docker::params::manage_package,
  $package_source                    = $docker::params::package_source,
  $manage_epel                       = $docker::params::manage_epel,
  $package_name                      = $docker::params::package_name,
  $service_name                      = $docker::params::service_name,
  $docker_command                    = $docker::params::docker_command,
  $daemon_subcommand                 = $docker::params::daemon_subcommand,
  $docker_users                      = [],
  $repo_opt                          = $docker::params::repo_opt,
  $nowarn_kernel                     = $docker::params::nowarn_kernel,
  $storage_devs                      = $docker::params::storage_devs,
  $storage_vg                        = $docker::params::storage_vg,
  $storage_root_size                 = $docker::params::storage_root_size,
  $storage_data_size                 = $docker::params::storage_data_size,
  $storage_min_data_size             = $docker::params::storage_min_data_size,
  $storage_chunk_size                = $docker::params::storage_chunk_size,
  $storage_growpart                  = $docker::params::storage_growpart,
  $storage_auto_extend_pool          = $docker::params::storage_auto_extend_pool,
  $storage_pool_autoextend_threshold = $docker::params::storage_pool_autoextend_threshold,
  $storage_pool_autoextend_percent   = $docker::params::storage_pool_autoextend_percent,
  $storage_config                    = $docker::params::storage_config,
  $storage_config_template           = $docker::params::storage_config_template,
  $service_provider                  = $docker::params::service_provider,
  $service_config                    = $docker::params::service_config,
  $service_config_template           = $docker::params::service_config_template,
  $service_overrides_template        = $docker::params::service_overrides_template,
  $service_hasstatus                 = $docker::params::service_hasstatus,
  $service_hasrestart                = $docker::params::service_hasrestart,
) inherits docker::params {

  validate_string($version)
  validate_re($::osfamily, '^(Debian|RedHat|Archlinux|Gentoo)$', 'This module only works on Debian or Red Hat based systems or on Archlinux as on Gentoo.')
  validate_bool($manage_kernel)
  validate_bool($manage_package)
  validate_bool($docker_cs)
  validate_bool($manage_service)
  validate_array($docker_users)
  validate_array($log_opt)
  validate_bool($tls_enable)
  validate_bool($ip_forward)
  validate_bool($iptables)
  validate_bool($ip_masq)
  validate_string($bridge)
  validate_string($fixed_cidr)
  validate_string($default_gateway)
  validate_string($bip)

  if ($fixed_cidr or $default_gateway) and (!$bridge) {
    fail('You must provide the $bridge parameter.')
  }

  if $log_level {
    validate_re($log_level, '^(debug|info|warn|error|fatal)$', 'log_level must be one of debug, info, warn, error or fatal')
  }

  if $log_driver {
    validate_re($log_driver, '^(none|json-file|syslog|journald|gelf|fluentd)$', 'log_driver must be one of none, json-file, syslog, journald, gelf or fluentd')
  }

  if $selinux_enabled {
    validate_re($selinux_enabled, '^(true|false)$', 'selinux_enabled must be true or false')
  }

  if $storage_driver {
    validate_re($storage_driver, '^(aufs|devicemapper|btrfs|overlay|vfs|zfs)$', 'Valid values for storage_driver are aufs, devicemapper, btrfs, overlay, vfs, zfs.' )
  }

  if $dm_fs {
    validate_re($dm_fs, '^(ext4|xfs)$', 'Only ext4 and xfs are supported currently for dm_fs.')
  }

  if ($dm_loopdatasize or $dm_loopmetadatasize) and ($dm_datadev or $dm_metadatadev) {
    fail('You should provide parameters only for loop lvm or direct lvm, not both.')
  }

  if ($dm_datadev or $dm_metadatadev) and $dm_thinpooldev {
    fail('You can use the $dm_thinpooldev parameter, or the $dm_datadev and $dm_metadatadev parameter pair, but you cannot use both.')
  }

  if ($dm_datadev or $dm_metadatadev) {
    notice('The $dm_datadev and $dm_metadatadev parameter pair are deprecated.  The $dm_thinpooldev parameter should be used instead.')
  }

  if ($dm_datadev and !$dm_metadatadev) or (!$dm_datadev and $dm_metadatadev) {
    fail('You need to provide both $dm_datadev and $dm_metadatadev parameters for direct lvm.')
  }

  if ($dm_basesize or $dm_fs or $dm_mkfsarg or $dm_mountopt or $dm_blocksize or $dm_loopdatasize or $dm_loopmetadatasize or $dm_datadev or $dm_metadatadev) and ($storage_driver != 'devicemapper') {
    fail('Values for dm_ variables will be ignored unless storage_driver is set to devicemapper.')
  }

  if($tls_enable) {
    if(!$tcp_bind) {
        fail('You need to provide tcp bind parameter for TLS.')
    }
    validate_string($tls_cacert)
    validate_string($tls_cert)
    validate_string($tls_key)
  }

  class { 'docker::repos': } ->
  class { 'docker::install': } ->
  class { 'docker::config': } ~>
  class { 'docker::service': }
  contain 'docker::repos'
  contain 'docker::install'
  contain 'docker::config'
  contain 'docker::service'

  Class['docker'] -> Docker::Registry <||> -> Docker::Image <||> -> Docker::Run <||>
  Class['docker'] -> Docker::Image <||> -> Docker::Run <||>
  Class['docker'] -> Docker::Run <||>
}
