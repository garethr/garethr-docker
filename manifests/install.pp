# == Class: docker
#
# Module to install an up-to-date version of Docker from a package repository.
# This module currently works only on Debian, Red Hat
# and Archlinux based distributions.
#
class docker::install {
  validate_string($docker::version)
  validate_re($::osfamily, '^(Debian|RedHat|Archlinux)$', 'This module only works on Debian, Red Hat and Archlinux based systems.')
  validate_string($::kernelrelease)
  validate_bool($docker::use_upstream_package_source)

  case $::osfamily {
    'Debian': {
      ensure_packages($docker::prerequired_packages, {'ensure' => 'latest'})
      if $docker::manage_package {
        Package['apt-transport-https'] -> Package['docker']
      }

      if $docker::version {
        $dockerpackage = "${docker::package_name}-${docker::version}"
      } else {
        $dockerpackage = $docker::package_name
      }

      if ($docker::use_upstream_package_source) {
        include apt
        apt::source { 'docker':
          location          => $docker::package_source_location,
          release           => 'docker',
          repos             => 'main',
          required_packages => 'debian-keyring debian-archive-keyring',
          key               => 'A88D21E9',
          key_source        => 'http://get.docker.io/gpg',
          pin               => '10',
          include_src       => false,
        }
        if $docker::manage_package {
          Apt::Source['docker'] -> Package['docker']
        }
      } else {
        if $docker::version and $docker::ensure != 'absent' {
          $ensure = $docker::version
        } else {
          $ensure = $docker::ensure
        }
      }

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
      if versioncmp($::operatingsystemrelease, '6.5') < 0 {
        fail('Docker needs RedHat/CentOS version to be at least 6.5.')
      }

      $manage_kernel = false

      if $docker::version {
        $dockerpackage = "${docker::package_name}-${docker::version}"
      } else {
        $dockerpackage = $docker::package_name
      }

      if ($docker::use_upstream_package_source) {
        include 'epel'
        if $docker::manage_package {
          Class['epel'] -> Package['docker']
        }
      }
    }
    'Archlinux': {
      $manage_kernel = false

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

  if $docker::manage_package {
    package { 'docker':
      ensure => $docker::ensure,
      name   => $dockerpackage,
    }
  }
}
