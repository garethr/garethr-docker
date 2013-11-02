# == Class: docker
#
# Module to install an up-to-date version of Docker from the
# official Apt repository. The use of this repository means, this module works
# only on Debian based distributions.
#
class docker::install {
  include apt
  validate_string($docker::version)
  validate_re($::osfamily, '^Debian$', 'This module uses the docker apt repo and only works on Debian systems that support it.')
  validate_string($::kernelrelease)

  apt::source { 'docker':
    location          => 'https://get.docker.io/ubuntu',
    release           => 'docker',
    repos             => 'main',
    required_packages => 'debian-keyring debian-archive-keyring',
    key               => 'A88D21E9',
    key_source        => 'http://get.docker.io/gpg',
    pin               => '10',
    include_src       => false,
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

  if $docker::manage_kernel {
    package { $kernelpackage:
      ensure => present,
    }
    Package[$kernelpackage] -> Package['lxc-docker']
  }

  package { 'lxc-docker':
    ensure  => $docker::version,
    require => Apt::Source['docker'],
  }

}
