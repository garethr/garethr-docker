# == Define: docker:run
#
# A define which manages an upstart managed docker container
#
define docker::run(
  $image,
  $command = undef,
  $memory_limit = '0',
  $ports = [],
  $volumes = [],
  $links = [],
  $use_name = false,
  $running = true,
  $volumes_from = [],
  $username = false,
  $hostname = false,
  $env = {},
  $dns = [],
  $lxc_conf = [],
  $restart_service = true,
  $disable_network = false,
) {
  validate_re($image, '^[\S]*$')
  validate_re($name, '^[\S]*$')
  validate_re($memory_limit, '^[\d]*$')
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
  if !is_array($env) and !is_hash($env) {
    fail('The "env" parameter must be a hash or array')
  }

  $ports_array = any2array($ports)
  $volumes_array = any2array($volumes)
  $dns_array = any2array($dns)
  $links_array = any2array($links)
  $lxc_conf_array = any2array($lxc_conf)

  case $::osfamily {
    'Debian': {
      $initscript = "/etc/init/docker-${name}.conf"

      $provider = $::operatingsystem ? {
        'Ubuntu' => 'upstart',
        default  => undef,
      }

      file { $initscript:
        ensure  => present,
        content => template('docker/etc/init/docker-run.conf.erb')
      }

      service { "docker-${name}":
        ensure     => $running,
        enable     => true,
        hasstatus  => true,
        provider   => $provider,
      }
    }
    'RedHat': {
      $initscript = "/etc/init.d/docker-${name}"

      file { $initscript:
        ensure  => present,
        content => template('docker/etc/init.d/docker-run.erb'),
        mode    => '0755',
      }

      service { "docker-${name}":
        ensure     => $running,
        enable     => true,
      }
    }
    default: {
      fail('Docker needs a RedHat or Debian based system.')
    }
  }

  if str2bool($restart_service) {
    File[$initscript] ~> Service["docker-${name}"]
  }
  else {
    File[$initscript] -> Service["docker-${name}"]
  }
}

