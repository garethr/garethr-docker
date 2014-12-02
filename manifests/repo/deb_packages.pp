# == Class: docker::repo::deb_packages
#
# use puppetlabs/apt for $::osfamily: Debian

class docker::repo::deb_packages {

  if ($docker::use_upstream_package_source) {
    include apt
    apt::source { 'docker':
      location          => $docker::package_source_location,
      release           => 'docker',
      repos             => 'main',
      required_packages => 'debian-keyring debian-archive-keyring',
      key               => 'A88D21E9',
      key_source        => 'https://get.docker.io/gpg',
      pin               => '10',
      include_src       => false,
    }
    if $docker::manage_package {
      Apt::Source['docker'] -> Package['docker']
    }
  }

}

