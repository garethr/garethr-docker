# == Class: docker::compose
#
# Class to install Docker Compose using the recommended curl command.
#
# === Parameters
#
# [*ensure*]
#   Whether to install or remove Docker Compose
#   Valid values are absent present
#   Defaults to present
#
# [*compose_image*]
#   The docker image to pull and execute as the docker-compose command
#   Defaults to the value set in $docker::params::compose_iage
#
#
# [*compose_path*]
#   The absolute path to the compose executable
#   Defaults to the value set in $docker::params::compose_path
#
class docker::compose(
  $ensure = 'present',
  $compose_path = $docker::params::compose_path,
  $compose_image = $docker::params::compose_image,
) inherits docker::params {
  validate_re($ensure, '^(present|absent)$')
  validate_absolute_path($compose_path)

  if $ensure == 'present' {

    file { $compose_path:
      ensure  => 'file',
      owner   => 'root',
      mode    => '0755',
      content => template('docker/run.sh.erb')
    }

  } else {
    file {$compose_path:
      ensure => absent,
    }
  }
}
