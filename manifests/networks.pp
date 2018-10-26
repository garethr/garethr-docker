# docker_old::networks
class docker_old::networks($networks) {
  create_resources(docker_network, $networks)
}
