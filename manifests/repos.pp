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
        $apt_required_packages = [ 'debian-keyring', 'debian-archive-keyring', ]
        ensure_packages($apt_required_packages)
        apt::source { 'docker':
          location => $location,
          release  => $docker::package_release,
          repos    => $docker::package_repos,
          key      => {
            'id'     => $package_key,
            'source' => $key_source,
          },
          pin      => '10',
          include  => {
            'src' => false,
          },
          require  => Package[$apt_required_packages],
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
