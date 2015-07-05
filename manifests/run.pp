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
  include docker::params
  $docker_command = $docker::params::docker_command
  $service_name = $docker::params::service_name

  validate_re($image, '^[\S]*$')
  validate_re($title, '^[\S]*$')
  validate_re($memory_limit, '^[\d]*(b|k|m|g)$')
  if $restart {
    validate_re($restart, '^(no|always)|^on-failure:[\d]+$')
  }
  validate_string($docker_command)
  validate_string($service_name)
  if $command {
    validate_string($command)
  }
  if $username {
    validate_string($username)
  }
  if $hostname {
    validate_string($hostname)
  }
  validate_bool($running)
  validate_bool($disable_network)
  validate_bool($privileged)
  validate_bool($restart_service)
  validate_bool($tty)

  if $detach == undef {
    $valid_detach = $docker::params::detach_service_in_init
  } else {
    validate_bool($detach)
    $valid_detach = $detach
  }

  $depends_array = any2array($depends)

  $docker_run_flags = docker_run_flags({
    cpuset          => any2array($cpuset),
    detach          => $valid_detach,
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
    privileged      => $privileged,
    socket_connect  => any2array($socket_connect),
    tty             => $tty,
    username        => $username,
    volumes         => any2array($volumes),
    volumes_from    => any2array($volumes_from),
  })

  $sanitised_title = regsubst($title, '[^0-9A-Za-z.\-]', '-', 'G')
  if empty($depends_array) {
    $sanitised_depends_array = []
  }
  else {
    $sanitised_depends_array = regsubst($depends_array, '[^0-9A-Za-z.\-]', '-', 'G')
  }

  if $restart {

    $cidfile = "/var/run/docker-${sanitised_title}.cid"

    exec { "run ${title} with docker":
      command     => "${docker_command} run -d ${docker_run_flags} --cidfile=${cidfile} ${image} ${command}",
      unless      => "docker ps --no-trunc | grep `cat ${cidfile}`",
      environment => 'HOME=/root',
      path        => ['/bin', '/usr/bin'],
    }
  } else {

    case $::osfamily {
      'Debian': {
        $initscript = "/etc/init.d/${service_prefix}${sanitised_title}"
        $init_template = 'docker/etc/init.d/docker-run.erb'
        $deprecated_initscript = "/etc/init/${service_prefix}${sanitised_title}.conf"
        $hasstatus  = true
        $uses_systemd = false
        $mode = '0755'
      }
      'RedHat': {
        if ($::operatingsystem == 'Amazon') or (versioncmp($::operatingsystemrelease, '7.0') < 0) {
          $initscript     = "/etc/init.d/${service_prefix}${sanitised_title}"
          $init_template  = 'docker/etc/init.d/docker-run.erb'
          $hasstatus      = undef
          $mode           = '0755'
          $uses_systemd   = false
        } else {
          $initscript     = "/etc/systemd/system/${service_prefix}${sanitised_title}.service"
          $init_template  = 'docker/etc/systemd/system/docker-run.erb'
          $hasstatus      = true
          $mode           = '0644'
          $uses_systemd   = true
        }
      }
      'Archlinux': {
        $initscript     = "/etc/systemd/system/${service_prefix}${sanitised_title}.service"
        $init_template  = 'docker/etc/systemd/system/docker-run.erb'
        $hasstatus      = true
        $mode           = '0644'
        $uses_systemd   = true
      }
      default: {
        fail('Docker needs a Debian, RedHat or Archlinux based system.')
      }
    }

    file { $initscript:
      ensure  => present,
      content => template($init_template),
      mode    => $mode,
    }

    if $manage_service {
      # Transition help from moving from CID based container detection to
      # Name-based container detection. See #222 for context.
      # This code should be considered temporary until most people have
      # transitioned. - 2015-04-15
      if $initscript == "/etc/init.d/${service_prefix}${sanitised_title}" {
        # This exec sequence will ensure the old-style CID container is stopped
        # before we replace the init script with the new-style.
        exec { "/bin/sh /etc/init.d/${service_prefix}${sanitised_title} stop":
          onlyif  => "/usr/bin/test -f /var/run/docker-${sanitised_title}.cid && /usr/bin/test -f /etc/init.d/${service_prefix}${sanitised_title}",
          require => [],
        } ->
        file { "/var/run/docker-${sanitised_title}.cid":
          ensure => absent,
        } ->
        File[$initscript]
      }

      service { "${service_prefix}${sanitised_title}":
        ensure    => $running,
        enable    => true,
        hasstatus => $hasstatus,
        require   => File[$initscript],
      }
    }

    if $uses_systemd {
      File[$initscript] ~> Exec['docker-systemd-reload']
      Exec['docker-systemd-reload'] -> Service<| title == "${service_prefix}${sanitised_title}" |>
    }

    if $restart_service {
      File[$initscript] ~> Service<| title == "${service_prefix}${sanitised_title}" |>
    }
    else {
      File[$initscript] -> Service<| title == "${service_prefix}${sanitised_title}" |>
    }
  }
}
