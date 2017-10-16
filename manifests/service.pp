# == Class: docker::service
#
# Class to manage the docker service daemon
#
# === Parameters
# [*tcp_bind*]
#   Which tcp port, if any, to bind the docker service to.
#
# [*ip_forward*]
#   This flag interacts with the IP forwarding setting on
#   your host system's kernel
#
# [*iptables*]
#   Enable Docker's addition of iptables rules
#
# [*ip_masq*]
#   Enable IP masquerading for bridge's IP range.
#
# [*socket_bind*]
#   Which local unix socket to bind the docker service to.
#
# [*socket_group*]
#   Which local unix socket to bind the docker service to.
#
# [*root_dir*]
#   Specify a non-standard root directory for docker.
#
# [*extra_parameters*]
#   Plain additional parameters to pass to the docker daemon
#
# [*shell_values*]
#   Array of shell values to pass into init script config files
#
# [*manage_service*]
#   Specify whether the service should be managed.
#   Valid values are 'true', 'false'.
#   Defaults to 'true'.
#
class docker::service (
  $service_name                      = $docker::service_name,
  $service_state                     = $docker::service_state,
  $service_enable                    = $docker::service_enable,
  $manage_service                    = $docker::manage_service,
  $service_provider                  = $docker::service_provider,
  $service_hasstatus                 = $docker::service_hasstatus,
  $service_hasrestart                = $docker::service_hasrestart,
) {

  unless $::osfamily =~ /(Debian|RedHat|Archlinux|Gentoo)/ {
    fail('The docker::service class needs a Debian, RedHat, Archlinux or Gentoo based system.')
  }

  if $manage_service {
    service { 'docker':
      ensure     => $service_state,
      name       => $service_name,
      enable     => $service_enable,
      hasstatus  => $service_hasstatus,
      hasrestart => $service_hasrestart,
      provider   => $service_provider,
    }
  }
}
