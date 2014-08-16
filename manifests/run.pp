# == Define: docker:run
#
# A define which manages an upstart managed docker container
#
define docker::run(
  $image,
  $command = undef,
  $memory_limit = '0',
  $ports = [],
  $expose = [],
  $volumes = [],
  $links = [],
  $use_name = false,
  $running = true,
  $volumes_from = false,
  $net = 'bridge',
  $username = false,
  $hostname = false,
  $env = [],
  $dns = [],
  $lxc_conf = [],
  $restart_service = true,
  $disable_network = false,
  $privileged = false,
) {
  include docker::params
  $docker_command = $docker::params::docker_command
  $service_name = $docker::params::service_name

  validate_re($image, '^[\S]*$')
  validate_re($title, '^[\S]*$')
  validate_re($memory_limit, '^[\d]*$')
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

  $ports_array = any2array($ports)
  $expose_array = any2array($expose)
  $volumes_array = any2array($volumes)
  $env_array = any2array($env)
  $dns_array = any2array($dns)
  $links_array = any2array($links)
  $lxc_conf_array = any2array($lxc_conf)

  $sanitised_title = regsubst($title, '[^0-9A-Za-z.\-]', '-')

  $provider = $::operatingsystem ? {
    'Ubuntu' => 'upstart',
    default  => undef,
  }

  $notify = str2bool($restart_service) ? {
    true    => Service["docker-${sanitised_title}"],
    default => undef,
  }

  case $::osfamily {
    'Debian': {
      $initscript = "/etc/init/docker-${sanitised_title}.conf"
      $init_template = 'docker/etc/init/docker-run.conf.erb'
      $hasstatus  = true
      $hasrestart = false
      $mode = '0644'
    }
    'RedHat': {
      $initscript = "/etc/init.d/docker-${sanitised_title}"
      $init_template = 'docker/etc/init.d/docker-run.erb'
      $hasstatus  = undef
      $hasrestart = undef
      $mode = '0755'
    }
    default: {
      fail('Docker needs a RedHat or Debian based system.')
    }
  }

  file { $initscript:
    ensure  => present,
    content => template($init_template),
    mode    => $mode,
    notify  => $notify,
  }

  service { "docker-${sanitised_title}":
    ensure     => $running,
    enable     => true,
    hasstatus  => $hasstatus,
    hasrestart => $hasrestart,
    provider   => $provider,
    require    => File[$initscript],
  }

  if str2bool($restart_service) {
    File[$initscript] ~> Service["docker-${sanitised_title}"]
  }
  else {
    File[$initscript] -> Service["docker-${sanitised_title}"]
  }
}

