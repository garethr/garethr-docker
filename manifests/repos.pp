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
        } elsif ($docker::docker_ce) {
          $location = $docker::package_ce_source_location
          $key_source = $docker::package_ce_key_source
          $package_key = $docker::package_ce_key
        } else {
          $location = $docker::package_source_location
          $key_source = $docker::package_key_source
          $package_key = $docker::package_key
        }
        case $docker::docker_ce {
          true: {
            $release = $docker::package_ce_release
            $repos = $docker::package_ce_repos
          }
          default: {
            $release = $docker::package_release
            $repos = $docker::package_repos
          }
        }
        apt::source { 'docker':
          location          => $location,
          release           => $release,
          repos             => $repos,
          key               => $package_key,
          key_source        => $key_source,
          required_packages => 'debian-keyring debian-archive-keyring',
          include_src       => false,
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
        } elsif ($docker::docker_ce) {
          $baseurl = $docker::package_ce_source_location
          $gpgkey = undef
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
