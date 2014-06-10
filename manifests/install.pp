# == Class: docker
#
# Module to install an up-to-date version of Docker from a package repository.
# The use of this repository means, this module works only on Debian and Red
# Hat based distributions.
#
class docker::install {
  validate_string($docker::version)
  validate_re($::osfamily, '^(Debian|RedHat)$', 'This module only works on Debian and Red Hat based systems.')
  validate_string($::kernelrelease)
  validate_bool($docker::use_upstream_package_source)

$prerequired_packages = $::operatingsystem ? {
  'Debian' => ['apt-transport-https', 'cgroupfs-mount'],
  'Ubuntu' => ['apt-transport-https', 'cgroup-lite'],
  default  => '',
}

  case $::osfamily {
    'Debian': {

      ensure_packages($prerequired_packages)
      Package['apt-transport-https'] -> Package['docker']

      if ($docker::use_upstream_package_source) {

        if $docker::version {
          $dockerpackage = "lxc-docker-${docker::version}"
        } else {
          $dockerpackage = 'lxc-docker'
        }

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
          before            => Package['docker'],
        }
      } else {
        $dockerpackage = 'docker.io'

        if $docker::version and $docker::ensure != 'absent' {
          $ensure = $docker::version
        } else {
          $ensure = $docker::ensure
        }
      }

      if $::operatingsystem == 'Ubuntu' {
        case $::operatingsystemrelease {
          # On Ubuntu 12.04 (precise) install the backported 13.04 (raring) kernel
          '12.04': { $kernelpackage = [
                                        'linux-image-generic-lts-raring',
                                        'linux-headers-generic-lts-raring'
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
        $dockerpackage = "docker-io-${docker::version}"
      } else {
        $dockerpackage = 'docker-io'
      }

      if ($docker::use_upstream_package_source) {
        include 'epel'
        Class['epel'] -> Package['docker']
      }
    }
  }

  if $manage_kernel {
    package { $kernelpackage:
      ensure => present,
      before => Package['docker'],
    }
  }

  package { 'docker':
    ensure => $docker::ensure,
    name   => $dockerpackage,
  }
}
