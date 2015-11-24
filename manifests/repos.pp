# == Class: docker::repos
#
#
class docker::repos {

  ensure_packages($docker::prerequired_packages)

  case $::osfamily {
    'Debian': {
      include apt
      # apt-transport-https is required by the apt to get the sources
      ensure_packages(['apt-transport-https'])
      Package['apt-transport-https'] -> Apt::Source <||>
      if $::operatingsystem == 'Debian' and $::lsbdistcodename == 'wheezy' {
        include apt::backports
      }
      Exec['apt_update'] -> Package[$docker::prerequired_packages]
      if ($docker::use_upstream_package_source) {
        apt::source { 'docker':
          location          => $docker::package_source_location,
          release           => $docker::package_release,
          repos             => $docker::package_repos,
          key               => $docker::package_key,
          key_source        => $docker::package_key_source,
          required_packages => 'debian-keyring debian-archive-keyring',
          pin               => '10',
          include_src       => false,
        }
        if $docker::manage_package {
          Apt::Source['docker'] -> Package['docker']
        }
      }

    }
    'RedHat': {
      if $docker::manage_package {
        if ($docker::use_upstream_package_source) {
          yumrepo { 'docker':
            baseurl  => $docker::package_source_location,
            gpgkey   => $docker::package_key_source,
            gpgcheck => true,
          }
          Yumrepo['docker'] -> Package['docker']
        }

        if ($::operatingsystem != 'Amazon') and ($::operatingsystem != 'Fedora') {
          if ($docker::manage_epel == true) {
            include 'epel'
            Class['epel'] -> Package['docker']
          }
        }
      }
    }
  }
}
