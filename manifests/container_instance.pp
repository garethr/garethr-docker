# docker::container_instance
class docker::container_instance($instance) {
  create_resources(docker::container, $instance)
}
