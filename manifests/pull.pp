define docker::pull($image = $title) {

  validate_re($image, '^[\S]*$')

  exec { "docker pull ${image}":
    path    => ['/bin', '/usr/bin'],
    unless  => "docker images | grep ^${image}",
    timeout => 0,
  }
}
