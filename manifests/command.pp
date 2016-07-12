# == Define: docker::command
#
# A define which creates a shell wrapper run a command inside docker container.
#
# == Parameters
#
# [*wrapper_path*]
# This is the absolute path to the command wrapper to create.  This defaults to
# the title of the resource.
#
# [*ensure*]
# Ensure the state of the wrapper script.  Defaults to 'file'.  May be set to
# 'absent' to remove obsolete commands.
#
# [*command*]
# This is the command to execute inside of the container.  Required.
#
# [*extra_parameters*]
# An array of additional command line arguments to pass to the `docker run`
# command. Useful for adding additional new or experimental options that the
# module does not yet support.
#
# [*owner*]
# Owner of the wrapper script.  Defaults to 'root'.
#
# [*group*]
# Group of the wrapper script.  Defaults to 'root'.
#
# [*mode*]
# Mode of the wrapper script.  Defaults to '0755'.
#
define docker::command(
  $image,
  $command,
  $wrapper_path = $title,
  $ensure = 'file',
  $memory_limit = '0b',
  $cpuset = [],
  $ports = [],
  $labels = [],
  $expose = [],
  $volumes = [],
  $links = [],
  $volumes_from = [],
  $net = 'bridge',
  $username = false,
  $hostname = false,
  $env = [],
  $env_file = [],
  $dns = [],
  $dns_search = [],
  $lxc_conf = [],
  $disable_network = false,
  $privileged = false,
  $detach = false,
  $extra_parameters = undef,
  $pull_on_start = false,
  $tty = false,
  $interactive = true,
  $rm = true,
  $socket_connect = [],
  $hostentries = [],
  $owner = 'root',
  $group = 'root',
  $mode = '0755',
) {
  include docker::params
  if ($socket_connect != []) {
    $sockopts = join(any2array($socket_connect), ',')
    $docker_command = "${docker::params::docker_command} -H ${sockopts}"
  }else {
    $docker_command = $docker::params::docker_command
  }

  validate_re($image, '^[\S]*$')
  validate_re($wrapper_path, '^\/[\S]+$')
  validate_re($command, '^\/.+$')
  validate_re($ensure, '^(file|absent)$')
  validate_re($memory_limit, '^[\d]*(b|k|m|g)$')
  validate_string($docker_command)
  if $username {
    validate_string($username)
  }
  if $hostname {
    validate_string($hostname)
  }
  validate_bool($disable_network)
  validate_bool($privileged)
  validate_bool($tty)
  validate_bool($interactive)
  validate_bool($rm)
  validate_bool($detach)

  $extra_parameters_array = any2array($extra_parameters)

  $docker_run_flags = docker_run_flags({
    cpuset          => any2array($cpuset),
    detach          => $detach,
    disable_network => $disable_network,
    dns             => any2array($dns),
    dns_search      => any2array($dns_search),
    env             => any2array($env),
    env_file        => any2array($env_file),
    expose          => any2array($expose),
    extra_params    => any2array($extra_parameters),
    hostentries     => any2array($hostentries),
    hostname        => $hostname,
    links           => any2array($links),
    lxc_conf        => any2array($lxc_conf),
    memory_limit    => $memory_limit,
    net             => $net,
    ports           => any2array($ports),
    labels          => any2array($labels),
    privileged      => $privileged,
    socket_connect  => any2array($socket_connect),
    tty             => $tty,
    interactive     => $interactive,
    rm              => $rm,
    username        => $username,
    volumes         => any2array($volumes),
    volumes_from    => any2array($volumes_from),
  })

  $sanitised_title = regsubst(regsubst($title, '[^0-9A-Za-z.\-]', '-', 'G'), '^-', '')

  file { $title:
    ensure  => $ensure,
    content => template('docker/docker-command.erb'),
    owner   => $owner,
    group   => $group,
    mode    => $mode,
  }
}
