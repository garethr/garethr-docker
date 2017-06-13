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
# [*image_digest*]
#   If you want a specific content digest of the image to be installed
#
# [*image_prune*]
#   If you want to remove all the images except the specified tag
#
# [*docker_file*]
#   If you want to add a docker image from specific docker file
#
# [*docker_tar*]
#   If you want to load a docker image from specific docker tar
#
define docker::image(
  $ensure       = 'present',
  $image        = $title,
  $image_tag    = undef,
  $image_digest = undef,
  $image_prune  = false,
  $force        = false,
  $docker_file  = undef,
  $docker_dir   = undef,
  $docker_tar   = undef,
) {
  include docker::params
  $docker_command = $docker::params::docker_command
  validate_re($ensure, '^(present|absent|latest)$')
  validate_re($image, '^[\S]*$')
  validate_bool($image_prune)
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

  if ($image_prune) and (!$image_tag) {
    fail 'docker::image $image_prune requires $image_tag to be set'
  }

  if ($docker_file) and ($docker_dir) {
    fail 'docker::image must not have both $docker_file and $docker_dir set'
  }

  if ($docker_file) and ($docker_tar) {
    fail 'docker::image must not have both $docker_file and $docker_tar set'
  }

  if ($docker_dir) and ($docker_tar) {
    fail 'docker::image must not have both $docker_dir and $docker_tar set'
  }

  if ($image_digest) and ($docker_file) {
    fail 'docker::image must not have both $image_digest and $docker_file set'
  }

  if ($image_digest) and ($docker_dir) {
    fail 'docker::image must not have both $image_digest and $docker_dir set'
  }

  if ($image_digest) and ($docker_tar) {
    fail 'docker::image must not have both $image_digest and $docker_tar set'
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
  } elsif $image_digest {
    $image_arg     = "${image}@${image_digest}"
    $image_remove  = "${docker_command} rmi ${image_force}${image}:${image_digest}"
    $image_find    = "${docker_command} images --digests | egrep '^(docker.io/)?${image} ' | awk '{ print \$3 }' | grep ^${image_digest}$"
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
      returns     => ['0', '2'],
      require     => File['/usr/local/bin/update_docker_image.sh'],
    }
  }

  if $image_tag {
    # get images with same image name, but other tags than given
    $images_to_prune = "${docker_command} images | egrep '^(docker.io/)?${image} ' | grep -v -P '${image}\\s+${image_tag}' | awk '{ print \$3 }'"

    $images_prune = "${docker_command} rmi -f $($images_to_prune)"

    exec { $images_prune:
      environment => 'HOME=/root',
      path        => ['/bin', '/usr/bin'],
      timeout     => 0,
      onlyif      => "$images_to_prune | grep -P '.'",
    }
  }
}
