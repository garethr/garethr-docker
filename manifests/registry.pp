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
# [*local_user*]
#   The local user to log in as. Docker will store credentials in this
#   users home directory
#
#
define docker::registry(
  $server      = $title,
  $ensure      = 'present',
  $username    = undef,
  $password    = undef,
  $email       = undef,
  $local_user  = 'root',
) {
  include docker::params

  validate_re($ensure, '^(present|absent)$')

  $docker_command = $docker::params::docker_command

  if $ensure == 'present' {
    if $username != undef and $password != undef and $email != undef {
      $auth_cmd = "${docker_command} login -u '${username}' -p \"\${password}\" -e '${email}' ${server}"
      $auth_environment = "password=${password}"
    }
    else {
      $auth_cmd = "${docker_command} login ${server}"
      $auth_environment = undef
    }
  }
  else {
    $auth_cmd = "${docker_command} logout ${server}"
    $auth_environment = undef
  }

  if $::osfamily == 'windows' {
    $registry_path = [$::docker_binpath]
    $registry_user = undef
    $registry_cwd = 'C:\\'
    $registry_logoutput = true
  } else {
    $registry_path = ['/bin', '/usr/bin']
    $registry_user = $local_user
    $registry_cwd = '/root'
    $registry_logoutput = undef
  }

  exec { "${title} auth":
    environment => $auth_environment,
    command     => $auth_cmd,
    logoutput   => $registry_logoutput,
    user        => $registry_user,
    cwd         => $registry_cwd,
    path        => $registry_path,
    timeout     => 0,
  }

}
