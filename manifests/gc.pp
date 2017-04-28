# = Class: docker::gc
#
# Run docker-gc hourly. This cleans up containers that exited more than an hour ago and images that don't belong to any
# remaining containers. See https://github.com/spotify/docker-gc for more info.
#
# This module is entirely optional, but makes no sense without docker installed :)
#
class docker::gc {
  include ::docker
  file { '/usr/local/bin/docker-gc.sh':
    mode   => '0755',
    owner  => 'root',
    group  => 'root',
    source => 'puppet:///modules/docker/docker-gc/docker-gc.sh'
  } ~>
  cron { 'dockergc':
    command => '/usr/local/bin/docker-gc.sh',
    user    => root,
    hour    => 1,
    minute  => 0
  }
}
