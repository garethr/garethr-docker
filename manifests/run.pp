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
  $lxc_conf = [],
  $restart_service = true,
  $disable_network = false,
  $privileged = false,
  $detach = false,
  $extra_parameters = undef,
  $depends = [],
) {
  include docker::params
  $docker_command = $docker::params::docker_command
  $service_name = $docker::params::service_name

  validate_re($image, '^[\S]*$')
  validate_re($title, '^[\S]*$')
  validate_re($memory_limit, '^[\d]*(b|k|m|g)$')
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
  validate_bool($detach)
  validate_bool($restart_service)

  $ports_array = any2array($ports)
  $expose_array = any2array($expose)
  $volumes_array = any2array($volumes)
  $volumes_from_array = any2array($volumes_from)
  $env_array = any2array($env)
  $dns_array = any2array($dns)
  $dns_search_array = any2array($dns_search)
  $links_array = any2array($links)
  $cpuset_array = any2array($cpuset)
  $lxc_conf_array = any2array($lxc_conf)
  $extra_parameters_array = any2array($extra_parameters)
  $depends_array = any2array($depends)

  $sanitised_title = regsubst($title, '[^0-9A-Za-z.\-]', '-', 'G')
  $sanitised_depends_array = regsubst($depends_array, '[^0-9A-Za-z.\-]', '-', 'G')

  $provider = $::operatingsystem ? {
    'Ubuntu' => 'upstart',
    default  => undef,
  }

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
