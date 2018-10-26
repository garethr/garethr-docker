# docker_old::run_instance
class docker_old::run_instance($instance) {
  create_resources(docker_old::run, $instance)
}
