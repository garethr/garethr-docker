# == Class: docker::repos
#
# dispatch repo installtion by $osfamily to ::(deb|yum)_packages

class docker::repos {

  case $::osfamily {
    'Debian': {
      include docker::repo::deb_packages
    }
    'Redhat': {
      include docker::repo::yum_packages
    }
    default: {
      notify { "${::osfamily} unsupported":
        message => "The gareth/docker module does not yet support ${::osfamily}, patches welcome",
      }
    }
  }

}

