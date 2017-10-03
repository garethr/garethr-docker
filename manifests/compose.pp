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
# [*version*]
#   The version of Docker Compose to install.
#   Defaults to the value set in $docker::params::compose_version
#
# [*install_path*]
#   The path where to install Docker Compose.
#   Defaults to the value set in $docker::params::compose_install_path
#
# [*proxy*]
#   Proxy to use for downloading Docker Compose.
#
class docker::compose(
  $ensure = 'present',
  $compose_path = $docker::params::compose_path,
  $compose_image = $docker::params::compose_image,
) inherits docker::params {
  validate_re($ensure, '^(present|absent)$')
  validate_absolute_path($install_path)

  if $ensure == 'present' {

    file { $compose_path:
      ensure  => 'file',
      owner   => 'root',
      mode    => '0755',
      content => template('docker/run.sh.erb')
    }

  } else {
    file { [
      "${install_path}/docker-compose-${version}",
      "${install_path}/docker-compose"
    ]:
      ensure => absent,
    }
  }
}
