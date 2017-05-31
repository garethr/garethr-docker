# = Define: docker::cert
#
# Install client certificates for docker to be able to connect to a private registry.
#
# === Parameters
#
# [*title*]
#   The full URL of the registry _including the port number_!
#
# [*ca_cert_target*]
#   The file path to the ca cert (will be symlinked to)
#
# [*client_cert_target*]
#   The file path to the client cert (will be symlinked to)
#
# [*client_key_target*]
#   The file path to the client key (will be symlinked to)
#
# === Examples
#
#  docker::cert { 'quay.io':
#    ca_cert_target     => '/etc/tls/quay.io/ca.crt',
#    client_cert_target => '/etc/tls/quay.io/client.cert',
#    client_key_target  => '/etc/tls/quay.io/client.key',
#  }
#
define docker::cert(
  $ca_cert_target     = undef,
  $client_cert_target = undef,
  $client_key_target  = undef,
) {
  validate_string($title, $ca_cert_target, $client_cert_target, $client_key_target)

  include ::docker

  $registry_cert_path   = "/etc/docker/certs.d/${title}"
  $registry_ca_cert     = "${registry_cert_path}/ca.crt"
  $registry_client_cert = "${registry_cert_path}/client.cert"
  $registry_client_key  = "${registry_cert_path}/client.key"

  file { 'docker_conf_dir' :
    ensure => directory,
    path   => '/etc/docker',
    mode   => '0400',
    owner  => root,
    group  => root,
  } ->
  file { 'cert_dir' :
    ensure => directory,
    path   => '/etc/docker/certs.d',
    mode   => '0400',
    owner  => root,
    group  => root,
  } ->
  file { $registry_cert_path :
    ensure => directory,
    path   => $registry_cert_path,
    mode   => '0400',
    owner  => root,
    group  => root,
  } ->
  file { $registry_ca_cert :
    ensure => link,
    target => $ca_cert_target,
    mode   => '0400',
    owner  => root,
    group  => root,
  } ->
  file { $registry_client_cert :
    ensure => link,
    target => $client_cert_target,
    mode   => '0400',
    owner  => root,
    group  => root,
  } ->
  file { $registry_client_key :
    ensure => link,
    target => $client_key_target,
    mode   => '0400',
    owner  => root,
    group  => root,
  } ~>
  Service['docker']
}
