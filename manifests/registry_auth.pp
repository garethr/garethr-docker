# docker_old::registry_auth
class docker_old::registry_auth($registries) {
  create_resources(docker_old::registry, $registries)
}
