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
class docker::compose(
  $ensure = 'present',
  $version = $docker::params::compose_version,
  $install_path = $docker::params::compose_install_path
) inherits docker::params {
  validate_string($version)
  validate_re($ensure, '^(present|absent)$')
  validate_absolute_path($install_path)

  if $ensure == 'present' {
    ensure_packages(['curl'])

    exec { "Install Docker Compose ${version}":
      path    => '/usr/bin/',
      cwd     => '/tmp',
      command => "curl -s -L https://github.com/docker/compose/releases/download/${version}/docker-compose-${::kernel}-x86_64 > ${install_path}/docker-compose-${version}",
      creates => "${install_path}/docker-compose-${version}",
      require => Package['curl'],
    } ->
    file { "${install_path}/docker-compose-${version}":
      owner => 'root',
      mode  => '0755'
    } ->
    file { "${install_path}/docker-compose":
      ensure => 'link',
      target => "${install_path}/docker-compose-${version}",
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
