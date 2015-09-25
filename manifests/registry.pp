# == Class: docker
#
# Module to configure private docker registries from which to pull Docker images
# If the registry does not require authentication, this module is not required.
#
# === Parameters
# [*server*]
#   The hostname and port of the private Docker registry. Ex: dockerreg:5000
#
# [*ensure*]
#   Whether or not you want to login or logout of a repository
#
# [*username*]
#   Username for authentication to private Docker registry.
#   auth is not required.
#
# [*password*]
#   Password for authentication to private Docker registry. Leave undef if
#   auth is not required.
#
# [*email*]
#   Email for registration to private Docker registry. Leave undef if
#   auth is not required.
#
#
define docker::registry(
  $server    = $title,
  $ensure    = 'present',
  $username  = undef,
  $password  = undef,
  $email     = undef,
) {
  include docker::params

  validate_re($ensure, '^(present|absent)$')

  $docker_command = $docker::params::docker_command

  if $ensure == 'present' {
    if $username != undef and $password != undef and $email != undef {
      $auth_cmd = "${docker_command} login -u '${username}' -p '${password}' -e '${email}' ${server}"
    }
    else {
      $auth_cmd = "${docker_command} login ${server}"
    }
  }
  else {
      $auth_cmd = "${docker_command} logout ${server}"
  }

  exec { "auth against ${server}":
    command => $auth_cmd,
    user    => 0,
    cwd     => '/root',
    path    => ['/bin', '/usr/bin'],
    timeout => 0,
  }

}
