# == Class: docker
#
# Module to install an up-to-date version of Docker from a package repository.
# This module currently works only on Debian, Red Hat
# and Archlinux based distributions.
#
class docker::install {
  $docker_command = $docker::params::docker_command
  validate_string($docker::version)
  validate_re($::osfamily, '^(Debian|RedHat|Archlinux)$', 'This module only works on Debian, Red Hat and Archlinux based systems.')
  validate_string($::kernelrelease)
  validate_bool($docker::use_upstream_package_source)

  case $::osfamily {
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
      # new versions are setup this way
      $real_docker_version = "${docker::version}-0~${::lsbdistcodename}"
    }
    'RedHat': {
      $real_docker_version = $docker::version
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
      $real_docker_version = $docker::ensure
      if $docker::version {
        notify { 'docker::version unsupported on Archlinux':
          message => 'Versions other than latest are not supported on Arch Linux. This setting will be ignored.'
        }
      }
    }
  }

  if $manage_kernel {
    package { $kernelpackage:
      ensure => present,
    }
    if $docker::manage_package {
      Package[$kernelpackage] -> Package['docker']
    }
  }

  # we are dealing with a version string, so ensure should be a version
  if $docker::version {
    if $docker::ensure == 'present' {
      $ensure = $real_docker_version
    } else {
      $ensure = $docker::ensure
    }
  } else {
    $ensure = $docker::ensure
  }

  if $docker::manage_package {

    if $docker::repo_opt {
      $docker_hash = { 'install_options' => $docker::repo_opt }
    } else {
      $docker_hash = {}
    }

    if $docker::package_source {
      case $::osfamily {
        'Debian' : {
          $pk_provider = 'dpkg'
        }
        'RedHat' : {
          $pk_provider = 'rpm'
        }
        default : {
          $pk_provider = undef
        }
      }

      ensure_resource('package', 'docker', merge($docker_hash, {
        ensure          => $ensure,
        provider        => $pk_provider,
        source          => $docker::package_source,
        name            => $docker::package_name,
      }))

    } else {
      ensure_resource('package', 'docker', merge($docker_hash, {
        ensure          => $ensure,
        name            => $docker::package_name,
      }))
    }
  }
}
