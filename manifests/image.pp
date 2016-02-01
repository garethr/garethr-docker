# == Class: docker
#
# Module to install an up-to-date version of a Docker image
# from the registry
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
# [*docker_file*]
#   If you want to add a docker image from specific docker file
#
# [*docker_tar*]
#   If you want to load a docker image from specific docker tar
#
define docker::image(
  $ensure    = 'present',
  $image     = $title,
  $image_tag = undef,
  $force     = false,
  $docker_file = undef,
  $docker_dir = undef,
  $docker_tar = undef,
) {
  include docker::params
  $docker_command = $docker::params::docker_command
  validate_re($ensure, '^(present|absent|latest)$')
  validate_re($image, '^[\S]*$')
  validate_bool($force)

  # Wrapper used to ensure images are up to date
  ensure_resource('file', '/usr/local/bin/update_docker_image.sh',
    {
      ensure  => $docker::params::ensure,
      owner   => 'root',
      group   => 'root',
      mode    => '0555',
      content => template('docker/update_docker_image.sh.erb'),
    }
  )

  if ($docker_file) and ($docker_dir) {
    fail 'docker::image must not have both $docker_file and $docker_dir set'
  }

  if ($docker_file) and ($docker_tar) {
    fail 'docker::image must not have both $docker_file and $docker_tar set'
  }

  if ($docker_dir) and ($docker_tar) {
    fail 'docker::image must not have both $docker_dir and $docker_tar set'
  }

  if $force {
    $image_force   = '-f '
  } else {
    $image_force   = ''
  }

  if $image_tag {
    $image_arg     = "${image}:${image_tag}"
    $image_remove  = "${docker_command} rmi ${image_force}${image}:${image_tag}"
    $image_find    = "${docker_command} images | egrep '^(docker.io/)?${image} ' | awk '{ print \$2 }' | grep ^${image_tag}$"
  } else {
    $image_arg     = $image
    $image_remove  = "${docker_command} rmi ${image_force}${image}"
    $image_find    = "${docker_command} images | cut -d ' ' -f 1 | egrep '^(docker\\.io/)?${image}$'"
  }

  if $docker_dir {
    $image_install = "${docker_command} build -t ${image_arg} ${docker_dir}"
  } elsif $docker_file {
    $image_install = "${docker_command} build -t ${image_arg} - < ${docker_file}"
  } elsif $docker_tar {
    $image_install = "${docker_command} load -i ${docker_tar}"
  } else {
    $image_install = "/usr/local/bin/update_docker_image.sh ${image_arg}"
  }

  if $ensure == 'absent' {
    exec { $image_remove:
      path    => ['/bin', '/usr/bin'],
      onlyif  => $image_find,
      timeout => 0,
    }
  } elsif $ensure == 'latest' {
    exec { "echo 'Update of ${image_arg} complete'":
      environment => 'HOME=/root',
      path        => ['/bin', '/usr/bin'],
      timeout     => 0,
      onlyif      => $image_install,
      require     => File['/usr/local/bin/update_docker_image.sh'],
    }
  } elsif $ensure == 'present' {
    exec { $image_install:
      unless      => $image_find,
      environment => 'HOME=/root',
      path        => ['/bin', '/usr/bin'],
      timeout     => 0,
      returns     => ['0', '1'],
      require     => File['/usr/local/bin/update_docker_image.sh'],
    }
  }

}
