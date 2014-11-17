# == Class: docker::repo::yum_packages
#
# use puppetlabs/epel for $::osfamily Redhat, unless Amazon

class docker::repo::yum_packages {

  if $::operatingsystem != 'Amazon' {
    if ($docker::use_upstream_package_source) {
      include epel
      if $docker::manage_package {
        Class['epel'] -> Package['docker']
      }
    }
  }

}

