# docker_old::images
class docker_old::images($images) {
  create_resources(docker_old::image, $images)
}
