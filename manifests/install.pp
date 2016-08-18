# == Class: docker
#
# Module to install an up-to-date version of Docker from a package repository.
# This module currently works only on Debian, Red Hat
# and Archlinux based distributions.
#
class docker::install {
  $docker_command = $docker::docker_command
  validate_string($docker::version)
  validate_re($::osfamily, '^(Debian|RedHat|Archlinux|Gentoo|windows)$',
              'This module only works on Debian or Red Hat based systems, Archlinux as on Gentoo, or Windows.')
  validate_bool($docker::use_upstream_package_source)

  if $docker::version and $docker::ensure != 'absent' {
    $ensure = $docker::version
  } else {
    $ensure = $docker::ensure
  }

  case $::osfamily {
    'windows': {
      if versioncmp($::operatingsystemrelease, '10') < 0 {
        fail('Docker needs Windows version to be 10')
      }
      $manage_kernel = false
    }
    'Debian': {
      if $::operatingsystem == 'Ubuntu' {
        case $::operatingsystemrelease {
          # On Ubuntu 12.04 (precise) install the backported 13.10 (saucy) kernel
          '12.04': { $kernelpackage = [
                                        'linux-image-generic-lts-trusty',
                                        'linux-headers-generic-lts-trusty'
                                      ]
          }
          # determine the package name for 'linux-image-extra-$(uname -r)' based
          # on the $::kernelrelease fact
          default: { $kernelpackage = "linux-image-extra-${::kernelrelease}" }
        }
        $manage_kernel = $docker::manage_kernel
      } else {
        # Debian does not need extra kernel packages
        $manage_kernel = false
      }
    }
    'RedHat': {
      if $::operatingsystem == 'Amazon' {
        if versioncmp($::operatingsystemrelease, '3.10.37-47.135') < 0 {
          fail('Docker needs Amazon version to be at least 3.10.37-47.135.')
        }
      }
      elsif versioncmp($::operatingsystemrelease, '6.5') < 0 {
        fail('Docker needs RedHat/CentOS version to be at least 6.5.')
      }
      $manage_kernel = false
    }
    'Archlinux': {
      $manage_kernel = false
      if $docker::version {
        notify { 'docker::version unsupported on Archlinux':
          message => 'Versions other than latest are not supported on Arch Linux. This setting will be ignored.'
        }
      }
    }
    'Gentoo': {
      $manage_kernel = false
    }
    default: {}
  }

  if $manage_kernel {
    package { $kernelpackage:
      ensure => present,
    }
    if $docker::manage_package {
      Package[$kernelpackage] -> Package['docker']
    }
  }

  if $docker::manage_package {
    if empty($docker::repo_opt) {
      $docker_hash = {}
    } else {
      $docker_hash = { 'install_options' => $docker::repo_opt }
    }

    if $::osfamily == 'windows' {
      $download_url = $docker::msi_download_url

      exec { 'install_docker_msi_windows':
        command     => template('docker/install_docker_msi.ps1.erb'),
        environment => 'HOME=C:\\',
        creates     => "${docker::params::all_users_profile}\\InstallDocker.msi",
        provider    => 'powershell',
        logoutput   => true,
        timeout     => $docker::params::docker_install_timeout_seconds,
      }
    }

    if $docker::package_source {
      $install_package_source = $docker::package_source

      case $::osfamily {
        'Debian' : {
          $pk_provider = 'dpkg'
        }
        'RedHat' : {
          $pk_provider = 'rpm'
        }
        'Gentoo' : {
          $pk_provider = 'portage'
        }
        'windows' : {
          $pk_provider = undef
          $install_package_source = "${docker::params::all_users_profile}\\InstallDocker.msi"
        }
        default : {
          $pk_provider = undef
        }
      }

      ensure_resource('package', 'docker', merge($docker_hash, {
        ensure   => $ensure,
        provider => $pk_provider,
        source   => $install_package_source,
        name     => $docker::package_name,
      }))

    } else {
      if $::osfamily == 'windows' {
        $install_package_source = "${docker::params::all_users_profile}\\InstallDocker.msi"
      } else {
        $install_package_source = undef
      }

      ensure_resource('package', 'docker', merge($docker_hash, {
        ensure => $ensure,
        source => $install_package_source,
        name   => $docker::package_name,
      }))
    }
  }
}
