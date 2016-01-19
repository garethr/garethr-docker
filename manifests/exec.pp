
#
# A define which executes a command inside a container.
#
define docker::exec(
  $detach = false,
  $interactive = false,
  $tty = false,
  $container = undef,
  $command = undef,
  $unless = undef,
  $sanitise_name = true,
) {
  include docker::params

  $docker_command = $docker::params::docker_command
  validate_string($docker_command)

  validate_string($container)
  validate_string($command)
  validate_string($unless)
  validate_bool($detach)
  validate_bool($interactive)
  validate_bool($tty)

  $docker_exec_flags = docker_exec_flags({
    detach => $detach,
    interactive => $interactive,
    tty => $tty,
  })


  if $sanitise_name {
    $sanitised_container = regsubst($container, '[^0-9A-Za-z.\-]', '-', 'G')
  } else {
    $sanitised_container = $container
  }
  $exec = "${docker_command} exec ${docker_exec_flags} ${sanitised_container} ${command}"
  $unless_command = $unless ? {
      undef              => undef,
      ''                 => undef,
      default            => "${docker_command} exec ${docker_exec_flags} ${sanitised_container} ${$unless}",
  }

  exec { $exec:
    environment => 'HOME=/root',
    path        => ['/bin', '/usr/bin'],
    timeout     => 0,
    unless      => $unless_command,
  }
}
