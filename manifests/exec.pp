# == Define: docker:exec
#
# A define which executes a command inside a container.
#
define docker::exec(
  $detach = false,
  $interactive = false,
  $tty = false,
  $container = undef,
  $command = undef,
) {
  include docker::params

  $docker_command = $docker::params::docker_command
  validate_string($docker_command)

  validate_string($container)
  validate_string($command)
  validate_bool($detach)
  validate_bool($interactive)
  validate_bool($tty)

  $docker_exec_flags = docker_exec_flags({
    detach => $detach,
    interactive => $interactive,
    tty => $tty,
  })

  $exec = "${docker_command} exec ${docker_exec_flags} ${container} ${command}"

  exec { $exec:
    environment => 'HOME=/root',
    path        => ['/bin', '/usr/bin'],
    timeout     => 0,
  }
}
