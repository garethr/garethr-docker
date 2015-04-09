# == Define: docker:run
#
# A define which manages an upstart managed docker container
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
  $dns = [],
  $dns_search = [],
  $bridge_ip = undef,
  $lxc_conf = [],
  $restart_service = true,
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

  $extra_parameters_array = any2array($extra_parameters)
  $depends_array = any2array($depends)

  $docker_run_flags = docker_run_flags({
    cpuset => any2array($cpuset),
    detach => $valid_detach,
    disable_network => $disable_network,
    dns => any2array($dns),
    dns_search => any2array($dns_search),
    env => any2array($env),
    expose => any2array($expose),
    hostname => $hostname,
    bridge_ip => $bridge_ip,
    links => any2array($links),
    lxc_conf => any2array($lxc_conf),
    memory_limit => $memory_limit,
    net => $net,
    ports => any2array($ports),
    privileged => $privileged,
    username => $username,
    volumes => any2array($volumes),
    volumes_from => any2array($volumes_from),
    tty => $tty,
    socket_connect => any2array($socket_connect),
    hostentries => any2array($hostentries),
  })

  $sanitised_title = regsubst($title, '[^0-9A-Za-z.\-]', '-', 'G')
  $sanitised_depends_array = regsubst($depends_array, '[^0-9A-Za-z.\-]', '-', 'G')

  $provider = $::operatingsystem ? {
    'Ubuntu' => 'upstart',
    default  => undef,
  }

  if $restart {

    $cidfile = "/var/run/docker-${sanitised_title}.cid"

    exec { "run ${title} with docker":
      command     => "${docker_command} run -d ${docker_run_flags}  --cidfile=${cidfile} ${image} ${command}",
      unless      => 'docker ps --no-trunc | grep `cat $cidfile`',
      environment => 'HOME=/root',
      path        => ['/bin', '/usr/bin'],
    }

  } else {

    case $::osfamily {
      'Debian': {
        $initscript = "/etc/init.d/docker-${sanitised_title}"
        $init_template = 'docker/etc/init.d/docker-run.erb'
        $deprecated_initscript = "/etc/init/docker-${sanitised_title}.conf"
        $hasstatus  = true
        $hasrestart = false
        $uses_systemd = false
        $mode = '0755'

        # When switching between styles of init scripts (e.g. upstart and sysvinit),
        # we want to stop the service using the old init script. Since `service` will
        # prefer a sysvinit style script over an upstart one if both exist, we need
        # to stop the service before adding the sysvinit script.
        exec { "/usr/sbin/service docker-${sanitised_title} stop":
          onlyif  => "/usr/bin/test -f ${deprecated_initscript}"
        } ->
        file { $deprecated_initscript:
          ensure => absent
        } ->
        File[$initscript]
      }
      'RedHat': {
        if versioncmp($::operatingsystemrelease, '7.0') < 0 {
          $initscript     = "/etc/init.d/docker-${sanitised_title}"
          $init_template  = 'docker/etc/init.d/docker-run.erb'
          $hasstatus      = undef
          $hasrestart     = undef
          $mode           = '0755'
          $uses_systemd   = false
        } else {
          $initscript     = "/etc/systemd/system/docker-${sanitised_title}.service"
          $init_template  = 'docker/etc/systemd/system/docker-run.erb'
          $hasstatus      = true
          $hasrestart     = true
          $mode           = '0644'
          $uses_systemd   = true
        }
      }
      'Archlinux': {
        $initscript     = "/etc/systemd/system/docker-${sanitised_title}.service"
        $init_template  = 'docker/etc/systemd/system/docker-run.erb'
        $hasstatus      = true
        $hasrestart     = true
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

    service { "docker-${sanitised_title}":
      ensure     => $running,
      enable     => true,
      hasstatus  => $hasstatus,
      hasrestart => $hasrestart,
      provider   => $provider,
      require    => File[$initscript],
    }

    if $uses_systemd {
      File[$initscript] ~> Exec['docker-systemd-reload']
      Exec['docker-systemd-reload'] -> Service["docker-${sanitised_title}"]
    }

    if $restart_service {
      File[$initscript] ~> Service["docker-${sanitised_title}"]
    }
    else {
      File[$initscript] -> Service["docker-${sanitised_title}"]
    }
  }
}
