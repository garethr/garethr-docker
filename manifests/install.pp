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

  case $::osfamily {
    'Debian': {
      if ($docker::use_upstream_package_source) {
        include apt
        apt::source { 'docker':
          location          => $docker::apt_source_location,
          release           => 'docker',
          repos             => 'main',
          required_packages => 'debian-keyring debian-archive-keyring',
          key               => 'A88D21E9',
          key_source        => 'http://get.docker.io/gpg',
          pin               => '10',
          include_src       => false,
        }

        Apt::Source['docker'] -> Package['lxc-docker']
      }

      case $::operatingsystemrelease {
        # On Ubuntu 12.04 (precise) install the backported 13.04 (raring) kernel
        '12.04': { $kernelpackage = [
                                      'linux-image-generic-lts-raring',
                                      'linux-headers-generic-lts-raring'
                                    ]
        }
        # determine the package name for 'linux-image-extra-$(uname -r)' based on
        # the $::kernelrelease fact
        default: { $kernelpackage = "linux-image-extra-${::kernelrelease}" }
      }

      $dockerbasepkg = 'lxc-docker'
    }
    'RedHat': {
      if versioncmp($::operatingsystemrelease, '6.5') < 0 {
        fail('Docker needs RedHat/CentOS > 6.5.')
      }

      $dockerbasepkg = 'docker-io'
    }
  }

  if $docker::manage_kernel {
    package { $kernelpackage:
      ensure => present,
      before => Package[$dockerbasepkg],
    }
  }

  if $docker::version {
    $dockerpackage = "${dockerbasepkg}-${docker::version}"
  } else {
    $dockerpackage = $dockerbasepkg
  }

  package { $dockerbasepkg:
    ensure => $docker::ensure,
    name   => $dockerpackage,
  }
}
