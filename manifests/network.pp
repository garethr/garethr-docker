# docker::network
class docker::network($network) {
  create_resources(docker_network, $network)
}
