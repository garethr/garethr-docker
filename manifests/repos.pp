# == Class: docker::repos
#
#
class docker::repos {

  ensure_packages($docker::prerequired_packages)

  case $::osfamily {
    'Debian': {
      if ($docker::use_upstream_package_source) {
        if ($docker::docker_cs) {
          $location = $docker::package_cs_source_location
          $key_source = $docker::package_cs_key_source
          $package_key = $docker::package_cs_key
        } else {
          $location = $docker::package_source_location
          $key_source = $docker::package_key_source
          $package_key = $docker::package_key
        }
        ensure_packages(['debian-keyring', 'debian-archive-keyring'])
        apt::source { 'docker':
          location          => $location,
          release           => $docker::package_release,
          repos             => $docker::package_repos,
          key               => {
            id              => $package_key,
            source          => $key_source },
          require           => [ Package['debian-keyring'], Package['debian-archive-keyring'] ],
          include           => {
            src             => false },
        }
        $url_split = split($location, '/')
        $repo_host = $url_split[2]
        $pin_ensure = $docker::pin_upstream_package_source ? {
            true    => 'present',
            default => 'absent',
        }
        apt::pin { 'docker':
          ensure   => $pin_ensure,
          origin   => $repo_host,
          priority => $docker::apt_source_pin_level,
        }
        if $docker::manage_package {
          include apt
          if $::operatingsystem == 'Debian' and $::lsbdistcodename == 'wheezy' {
            include apt::backports
          }
          Exec['apt_update'] -> Package[$docker::prerequired_packages]
          Apt::Source['docker'] -> Package['docker']
        }
      }

    }
    'RedHat': {
      if $docker::manage_package {
        if ($docker::docker_cs) {
          $baseurl = $docker::package_cs_source_location
          $gpgkey = $docker::package_cs_key_source
        } else {
          $baseurl = $docker::package_source_location
          $gpgkey = $docker::package_key_source
        }
        if ($docker::use_upstream_package_source) {
          yumrepo { 'docker':
            descr    => 'Docker',
            baseurl  => $baseurl,
            gpgkey   => $gpgkey,
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
    default: {}
  }
}
