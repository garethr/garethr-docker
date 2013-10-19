define docker::image(
  $ensure = 'present',
  $image  = $title,
  $image_tag    = undef
) {

  validate_re($ensure, '^(present|absent)$')
  validate_re($image, '^[\S]*$')

    if $image_tag {
      $image_install = "docker pull -t=\"${image_tag}\" ${image}"
      $image_remove  = "docker rmi ${image}:${image_tag}"
      $image_find    = "docker images | grep ^${image} | awk '{ print \$2 }' | grep ${image_tag}"
    } else {
      $image_install = "docker pull ${image}"
      $image_remove  = "docker rmi ${image}"
      $image_find    = "docker images | grep ^${image}"
    }


  if $ensure == 'absent' {
    exec { $image_remove:
      path    => ['/bin', '/usr/bin'],
      onlyif  => $image_find,
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
