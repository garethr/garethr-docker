# == Class: docker::config
#
class docker::config (
  $create_user = true
){
  docker::system_user { $docker::docker_users:
    create_user => $create_user
  }
}
