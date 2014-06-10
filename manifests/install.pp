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

      ensure_packages(['apt-transport-https', 'cgroup-lite'])
      Package['apt-transport-https'] -> Package['docker']

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

        Apt::Source['docker'] -> Package['docker']
      }

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

      $dockerbasepkg = 'lxc-docker'
      $manage_kernel = $docker::manage_kernel
    }
    'RedHat': {
      if versioncmp($::operatingsystemrelease, '6.5') < 0 {
        fail('Docker needs RedHat/CentOS version to be at least 6.5.')
      }

      $dockerbasepkg = 'docker-io'
      $manage_kernel = false

      if ($docker::use_upstream_package_source) {
        include 'epel'
        Class['epel'] -> Package[$dockerbasepkg]
      }
    }
  }

  if $manage_kernel {
    package { $kernelpackage:
      ensure => present,
      before => Package['docker'],
    }
  }

  $generic_versions = [
    'absent',
    'latest',
    'present',
  ]

  if $docker::version and member($generic_versions, $docker::version) {
    # Use distro-specific name with generic version.
    # IOW generic version overrides ensure.
    $dockerpackage = $dockerbasepkg
    $docker_ensure = $docker::version
  } elsif $docker::version {
    # Use distro-specific name with 'ensure present'
    # to preserve backward compatibility.
    $dockerpackage = "${dockerbasepkg}-${docker::version}"
    $docker_ensure = 'present'
  } else {
    # Use distro-specific name with $docker::ensure
    # to preserve backward compatibility.
    $dockerpackage = $dockerbasepkg
    $docker_ensure = $docker::ensure
  }

  package { 'docker':
    ensure => $docker_ensure,
    name   => $dockerpackage,
  }
}
