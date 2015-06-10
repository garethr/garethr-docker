#
#   Colin Wood <cwood@atlassian.com>
#   10-06-15
#
#   Clean up old docker images safely that have been removed.
#
class docker::cleanup {
  cron { 'docker rm':
    user    => 'root',
    command => 'docker rm $(docker ps --filter status=exited -q 2>/dev/null) 2>/dev/null',
    minute  => $docker::docker_cleanup_minute,
    hour    => $docker::docker_cleanup_hour,
  }
  cron { 'docker rmi':
    user    => 'root',
    command => 'docker rmi $(docker images --filter dangling=true -q 2>/dev/null) 2>/dev/null',
    minute  => $docker::docker_cleanup_minute,
    hour    => $docker::docker_cleanup_hour,
  }
}
