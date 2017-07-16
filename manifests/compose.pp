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
  $version = $docker::params::compose_version,
  $install_path = $docker::params::compose_install_path,
  $proxy = undef
) inherits docker::params {
  validate_string($version)
  validate_re($ensure, '^(present|absent)$')
  validate_absolute_path($install_path)
  if $proxy != undef {
      validate_re($proxy, '^(https?:\/\/)?([\da-z\.-]+)\.([a-z\.]{2,6})(:[\d])?([\/\w \.-]*)*\/?$')
  }

  if $ensure == 'present' {

    if ! defined(Package['curl']) {
      ensure_packages(['curl'])
    }

    if $proxy != undef {
        $proxy_opt = "--proxy ${proxy}"
    } else {
        $proxy_opt = ''
    }

    exec { "Install Docker Compose ${version}":
      path    => '/usr/bin/',
      cwd     => '/tmp',
      command => "curl -s -L ${proxy_opt} https://github.com/docker/compose/releases/download/${version}/docker-compose-${::kernel}-x86_64 > ${install_path}/docker-compose-${version}",
      creates => "${install_path}/docker-compose-${version}",
      require => Package['curl'],
    }

    file { "${install_path}/docker-compose-${version}":
      owner   => 'root',
      mode    => '0755',
      require => Exec["Install Docker Compose ${version}"]
    }

    file { "${install_path}/docker-compose":
      ensure  => 'link',
      target  => "${install_path}/docker-compose-${version}",
      require => File["${install_path}/docker-compose-${version}"]
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
