# == Class: docker
#
# Module to install an up-to-date version of Docker from the
# official Apt repository. The use of this repository means, this module works
# only on Debian based distributions.
#
# === Parameters
# [*ensure*]
#   Whether you want the image present or absent.
#
# [*image*]
#   If you want the name of the image to be different from the
#   name of the puppet resource you can pass a value here.
#
# [*image_tag*]
#   If you want a specific tag of the image to be installed
#
define docker::image(
  $ensure    = 'present',
  $image     = $title,
  $image_tag = undef,
) {
  include docker::params
  $docker_command = $docker::params::docker_command
  validate_re($ensure, '^(present|absent|latest)$')
  validate_re($image, '^[\S]*$')

  if $image_tag {
    $image_install = "${docker_command} pull -t=\"${image_tag}\" ${image}"
    $image_remove  = "${docker_command} rmi ${image}:${image_tag}"
    $image_find    = "${docker_command} images | grep ^${image} | awk '{ print \$2 }' | grep ${image_tag}"
  } else {
    $image_install = "${docker_command} pull ${image}"
    $image_remove  = "${docker_command} rmi ${image}"
    $image_find    = "${docker_command} images | grep ^${image}"
  }

  if $ensure == 'absent' {
    exec { $image_remove:
      path    => ['/bin', '/usr/bin'],
      onlyif  => $image_find,
      timeout => 0,
    }
  } elsif $ensure == 'latest' {
    exec { $image_install:
      path    => ['/bin', '/usr/bin'],
      timeout => 0,
    }
  } else {
    exec { $image_install:
      path    => ['/bin', '/usr/bin'],
      unless  => $image_find,
      timeout => 0,
    }
  }
}
