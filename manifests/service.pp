# == Class: docker::service
#
# Class to manage the docker service daemon
#
# === Parameters
# [*tcp_bind*]
#   Which tcp port, if any, to bind the docker service to.
#
# [*socket_bind*]
#   Which local unix socket to bind the docker service to.
#
# [*socket_group*]
#   Which local unix socket to bind the docker service to.
#
# [*root_dir*]
#   Specify a non-standard root directory for docker.
#
# [*extra_parameters*]
#   Plain additional parameters to pass to the docker daemon
#
# [*shell_values*]
#   Array of shell values to pass into init script config files
#
class docker::service (
  $docker_command                    = $docker::docker_command,
  $service_name                      = $docker::service_name,
  $tcp_bind                          = $docker::tcp_bind,
  $socket_bind                       = $docker::socket_bind,
  $log_level                         = $docker::log_level,
  $log_level                         = $docker::log_level,
  $log_driver                        = $docker::log_driver,
  $selinux_enabled                   = $docker::selinux_enabled,
  $socket_group                      = $docker::socket_group,
  $dns                               = $docker::dns,
  $dns_search                        = $docker::dns_search,
  $service_state                     = $docker::service_state,
  $service_enable                    = $docker::service_enable,
  $root_dir                          = $docker::root_dir,
  $extra_parameters                  = $docker::extra_parameters,
  $shell_values                      = $docker::shell_values,
  $proxy                             = $docker::proxy,
  $no_proxy                          = $docker::no_proxy,
  $execdriver                        = $docker::execdriver,
  $storage_driver                    = $docker::storage_driver,
  $dm_basesize                       = $docker::dm_basesize,
  $dm_fs                             = $docker::dm_fs,
  $dm_mkfsarg                        = $docker::dm_mkfsarg,
  $dm_mountopt                       = $docker::dm_mountopt,
  $dm_blocksize                      = $docker::dm_blocksize,
  $dm_loopdatasize                   = $docker::dm_loopdatasize,
  $dm_loopmetadatasize               = $docker::dm_loopmetadatasize,
  $dm_datadev                        = $docker::dm_datadev,
  $dm_metadatadev                    = $docker::dm_metadatadev,
  $tmp_dir                           = $docker::tmp_dir,
  $nowarn_kernel                     = $docker::nowarn_kernel,
  $dm_thinpooldev                    = $docker::dm_thinpooldev,
  $dm_use_deferred_removal           = $docker::dm_use_deferred_removal,
  $dm_blkdiscard                     = $docker::dm_blkdiscard,
  $dm_override_udev_sync_check       = $docker::dm_override_udev_sync_check,
  $storage_devs                      = $docker::storage_devs,
  $storage_vg                        = $docker::storage_vg,
  $storage_root_size                 = $docker::storage_root_size,
  $storage_data_size                 = $docker::storage_data_size,
  $storage_chunk_size                = $docker::storage_chunk_size,
  $storage_growpart                  = $docker::storage_growpart,
  $storage_auto_extend_pool          = $docker::storage_auto_extend_pool,
  $storage_pool_autoextend_threshold = $docker::storage_pool_autoextend_threshold,
  $storage_pool_autoextend_percent   = $docker::storage_pool_autoextend_percent,
) inherits docker::params {
  $dns_array = any2array($dns)
  $dns_search_array = any2array($dns_search)
  $extra_parameters_array = any2array($extra_parameters)
  $shell_values_array = any2array($shell_values)

  case $::osfamily {
    'Debian': {
      $service_config = "/etc/default/${service_name}"

      if $::operatingsystem == 'Ubuntu' and versioncmp($::operatingsystemrelease, '15.04') < 0 {
        $hasstatus  = true
        $hasrestart = false
        $provider   = 'upstart'

        file { '/etc/init.d/docker':
          ensure => 'link',
          target => '/lib/init/upstart-job',
          force  => true,
          notify => Service['docker'],
        }
      }

      if ($::operatingsystem == 'Debian' and versioncmp($::operatingsystemmajrelease, '8') >= 0) or ($::operatingsystem == 'Ubuntu' and versioncmp($::operatingsystemrelease, '15.04') >= 0) {
        $provider = 'systemd'
        $systemd_service_overrides_template = 'docker/etc/systemd/system/docker.service.d/service-overrides-debian.conf.erb'
        $service_config_template = 'docker/etc/sysconfig/docker.systemd.erb'

        file { '/etc/default/docker-storage':
          ensure  => present,
          force   => true,
          content => template('docker/etc/sysconfig/docker-storage.erb'),
          notify  => Service['docker'],
        }
      } else {
        $service_config_template = 'docker/etc/default/docker.erb'
      }
    }
    'RedHat': {
      $service_config = '/etc/sysconfig/docker'

      if ($::operatingsystem == 'Fedora') or (versioncmp($::operatingsystemrelease, '7.0') >= 0) {
        $provider = 'systemd'
        $service_config_template = 'docker/etc/sysconfig/docker.systemd.erb'

        file { '/etc/sysconfig/docker-storage-setup':
          ensure  => present,
          force   => true,
          content => template('docker/etc/sysconfig/docker-storage-setup.erb'),
          before  => Service['docker'],
          notify  => Service['docker'],
        }

        if ($docker::use_upstream_package_source) {
          $systemd_service_overrides_template = 'docker/etc/systemd/system/docker.service.d/service-overrides-rhel.conf.erb'
        }
      } else {
        $service_config_template = 'docker/etc/sysconfig/docker.erb'
      }

      file { '/etc/sysconfig/docker-storage':
        ensure  => present,
        force   => true,
        content => template('docker/etc/sysconfig/docker-storage.erb'),
        before  => Service['docker'],
        notify  => Service['docker'],
      }
    }
    'Archlinux': {
      $provider   = 'systemd'
      $systemd_service_overrides_template = 'docker/etc/systemd/system/docker.service.d/service-overrides-archlinux.conf.erb'
      $hasstatus  = true
      $hasrestart = true
      $service_config = '/etc/conf.d/docker'
      $service_config_template = 'docker/etc/conf.d/docker.erb'
    }
    default: {
      fail('Docker needs a Debian, RedHat or Archlinux based system.')
    }
  }

  if $provider == 'systemd' {
    file { '/etc/systemd/system/docker.service.d':
      ensure => directory
    }

    if $systemd_service_overrides_template {
      file { '/etc/systemd/system/docker.service.d/service-overrides.conf':
        ensure  => present,
        content => template($systemd_service_overrides_template),
        notify  => Exec['docker-systemd-reload']
      }
    }
  }

  if $service_config {
    file { $service_config:
      ensure  => present,
      force   => true,
      content => template($service_config_template),
      notify  => Service['docker'],
    }
  }

  service { 'docker':
    ensure     => $service_state,
    name       => $service_name,
    enable     => $service_enable,
    hasstatus  => $hasstatus,
    hasrestart => $hasrestart,
    provider   => $provider,
  }

}
