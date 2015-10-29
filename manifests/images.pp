# docker::images
class docker::images(
    $images = hiera_hash('docker::images')
) {
  create_resources(docker::image, $images)
}
