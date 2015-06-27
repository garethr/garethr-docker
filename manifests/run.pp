# == Define: docker:run
#
# A define which manages a running docker container.
#
# == Parameters
#
# [*restart*]
# Sets a restart policy on the docker run.
# Note: If set, puppet will NOT setup an init script to manage, instead
# it will do a raw docker run command using a CID file to track the container
# ID.
#
# If you want a normal named container with an init script and a restart policy
# you must use the extra_parameters feature and pass it in like this:
#
#    extra_parameters => ['--restart=always']
#
# This will allow the docker container to be restarted if it dies, without
# puppet help.
#
# [*service_prefix*]
#   (optional) The name to prefix the startup script with and the Puppet
#   service resource title with.  Default: 'docker-'
#
# [*restart_service*]
#   (optional) Whether or not to restart the service if the the generated init
#   script changes.  Default: true
#
# [*manage_service*]
#  (optional) Whether or not to create a puppet Service resource for the init
#  script.  Disabling this may be useful if integrating with existing modules.
#  Default: true
#
# [*extra_parameters*]
# An array of additional command line arguments to pass to the `docker run`
# command. Useful for adding additional new or experimental options that the
# module does not yet support.
#
define docker::run(
  $image,
  $command = undef,
  $memory_limit = '0b',
  $cpuset = [],
  $ports = [],
  $expose = [],
  $volumes = [],
  $links = [],
  $use_name = false,
  $running = true,
  $volumes_from = [],
  $net = 'bridge',
  $username = false,
  $hostname = false,
  $env = [],
  $env_file = [],
  $dns = [],
  $dns_search = [],
  $lxc_conf = [],
  $service_prefix = 'docker-',
  $restart_service = true,
  $manage_service = true,
  $disable_network = false,
  $privileged = false,
  $detach = undef,
  $extra_parameters = undef,
  $pull_on_start = false,
  $depends = [],
  $tty = false,
  $socket_connect = [],
  $hostentries = [],
  $restart = undef,
  $before_stop = false,
) {
  docker::container { $title :
    image            => $image,
    command          => $command,
    memory_limit     => $memory_limit,
    cpuset           => $cpuset,
    ports            => $ports,
    expose           => $expose,
    volumes          => $volumes,
    links            => $links,
    use_name         => $use_name,
    running          => $running,
    volumes_from     => $volumes_from,
    net              => $net,
    username         => $username,
    hostname         => $hostname,
    env              => $env,
    env_file         => $env_file,
    dns              => $dns,
    dns_search       => $dns_search,
    lxc_conf         => $lxc_conf,
    service_prefix   => 'docker-',
    restart_service  => $restart_service,
    manage_service   => true,
    disable_network  => $disable_network,
    privileged       => $privileged,
    detach           => $detach,
    extra_parameters => $extra_parameters,
    pull_on_start    => $pull_on_start,
    depends          => $depends,
    tty              => $tty,
    socket_connect   => $socket_connect,
    hostentries      => $hostentries,
    restart          => $restart,
    before_stop      => false,
  }
}
