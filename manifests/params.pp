# == Class: docker::params
#
# Default parameter values for the docker module
#
class docker::params {
  $version                      = undef
  $ensure                       = present
  $tcp_bind                     = undef
  $socket_bind                  = 'unix:///var/run/docker.sock'
  $socket_group                 = undef
  $use_upstream_package_source  = true
  $service_state                = running
  $service_enable               = true
  $root_dir                     = undef
  $tmp_dir                      = '/tmp/'
  $dns                          = undef
  $dns_search                   = undef
  $proxy                        = undef
  $no_proxy                     = undef
  $execdriver                   = undef
  $storage_driver               = undef
  $manage_package               = true
  $manage_kernel                = true
  $package_name_default         = 'lxc-docker'
  $service_name_default         = 'docker'
  $docker_command_default       = 'docker'
  case $::osfamily {
    'Debian' : {
      case $::operatingsystem {
        'Ubuntu' : {
          $package_name   = $package_name_default
          $service_name   = $service_name_default
          $docker_command = $docker_command_default
        }
        default: {
          $package_name   = 'docker.io'
          $service_name   = 'docker.io'
          $docker_command = 'docker.io'
        }
      }
      $package_source_location = 'https://get.docker.io/ubuntu'
    }
    'RedHat' : {
      if $::operatingsystem == 'Fedora' {
        $package_name   = 'docker-io'
      } elsif (versioncmp($::operatingsystemrelease, '7.0') < 0) and $::operatingsystem != 'Amazon' {
        $package_name   = 'docker-io'
      } else {
        $package_name   = 'docker'
      }
      $package_source_location = ''
      $service_name   = $service_name_default
      $docker_command = $docker_command_default
      unless versioncmp($::operatingsystemrelease, '7.0') < 0 {
        include docker::systemd_reload
      }
    }
    'Archlinux' : {
      $package_name   = 'docker'
      $package_source_location = ''
      $service_name   = $service_name_default
      $docker_command = $docker_command_default
      include docker::systemd_reload
      }
    default: {
      $package_source_location = ''
      $package_name   = $package_name_default
      $service_name   = $service_name_default
      $docker_command = $docker_command_default
    }
  }

  # Special extra packages are required on some OSes.
  # Specifically apparmor is needed for Ubuntu:
  # https://github.com/docker/docker/issues/4734
  $prerequired_packages = $::operatingsystem ? {
    'Debian' => ['apt-transport-https', 'cgroupfs-mount'],
    'Ubuntu' => ['apt-transport-https', 'cgroup-lite', 'apparmor'],
    default  => '',
  }

}
