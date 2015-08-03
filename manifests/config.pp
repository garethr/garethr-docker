# == Class: docker::config
#
class docker::config {
  docker::system_user { $docker::docker_users: }
}
