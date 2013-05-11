define docker::run(
  $image,
  $command,
  $memory_limit = '0',
  $ports = [],
  $volumes = [],
  $running = true,
) {

  validate_re($image, '^[\S]*$')
  validate_re($title, '^[\S]*$')
  validate_re($memory_limit, '^[\d]*$')
  validate_string($command)
  validate_bool($running)

  $ports_array = any2array($ports)
  $volumes_array = any2array($volumes)

  file { "/etc/init/docker-${title}.conf":
    ensure  => present,
    content => template('docker/etc/init/docker-run.conf.erb')
  }

  service { "docker-${title}":
    ensure     => $running,
    enable     => true,
    hasstatus  => true,
    hasrestart => true,
    provider   => upstart,
    require    => File["/etc/init/docker-${title}.conf"],
  }

}
