# == Class: docker_old::config
#
class docker_old::config {
  docker_old::system_user { $docker::docker_users: }
}
