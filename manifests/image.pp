define docker::image(
  $ensure = 'present',
  $image = $title,
) {

  validate_re($ensure, '^(present|absent)$')
  validate_re($image, '^[\S]*$')

  if $ensure == 'absent' {
    exec { "docker rm ${image}":
      path    => ['/bin', '/usr/bin'],
      onlyif  => "docker images | grep ^${image}",
      timeout => 0,
    }
  } else {
    exec { "docker pull ${image}":
      path    => ['/bin', '/usr/bin'],
      unless  => "docker images | grep ^${image}",
      timeout => 0,
    }
  }
}
