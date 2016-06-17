# == Class: docker
#
# Module to tag or untag Docker image.
# 
# If tag does not exists when it is removed - it will fail silently
# If tag does not exists when adding - it will fail loud
#
# === Parameters
# [*ensure*]
#   Whether you want the image tag be present or absent.
#
# [*image*]
#   If you want the name of the image to be different from the
#   name of the puppet resource you can pass a value here.
#
# [*image_tag*]
#   If you want a specific tag of the image to be tagged or removed
#
# [*new_image*]
#   New image name to be tagged. If you want the name of the image to be
#   different from the name of the puppet resource you can pass a value here.
#
# [*new_tag*]
#   New tag you want to set on the image
#
# [*force*]
#   Force changing or removing tag
#
define docker::tag(
  $ensure    = 'present',
  $image     = $title,
  $image_tag = 'latest',
  $new_image = $title,
  $new_tag   = undef,
  $force     = false
) {
  include docker::params
  $docker_command = $docker::params::docker_command
  validate_re($ensure, '^(present|absent)$')
  validate_re($image, '^[\S]+$')
  validate_re($image_tag, '^[\S]+$')
  validate_re($new_image, '^[\S]+$')

  if $ensure == 'present' {
    validate_re($new_tag, '^[\S]+$')
  }

  if $force {
    $image_force   = '-f '
  } else {
    $image_force   = ''
  }

  $image_arg = "${image}:${image_tag}"
  $image_tag_cmd = "${docker_command} tag ${image_force}${image}:${image_tag} ${new_image}:${new_tag}"
  $image_untag_cmd = "${docker_command} rmi ${image_force}${image}:${image_tag}"
  $image_find    = "${docker_command} images | egrep '^(docker.io/)?${image} ' | awk '{ print \$2 }' | grep ^${image_tag}$"

  if $ensure == 'absent' {
    exec { $image_untag_cmd:
      path   => ['/bin', '/usr/bin'],
      onlyif => $image_find
    }
  } elsif $ensure == 'present' {
    exec { $image_tag_cmd:
      environment => 'HOME=/root',
      path        => ['/bin', '/usr/bin'],
      onlyif => [
        "test \"`docker inspect -f '{{.Id}}' ${image}:${image_tag}`\" != \"`docker inspect -f '{{.Id}}' ${new_image}:${new_tag}`\" "
      ]
    }
  }
}
