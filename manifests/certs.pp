# = Class: docker::certs
#
# Install client certificates for docker to be able to connect to registry.tradeshift.com.
#
class docker::certs {
  include ::docker

  # TODO: Include certs correctly!
  file { '/etc/docker/certs.d/registry.tradeshift.com' :
    ensure => directory,
    mode   => '0400',
    owner  => root,
    group  => root
  } ->
  file { '/etc/docker/certs.d/registry.tradeshift.com/ca.crt' :
    ensure => link,
    target => '/etc/tradeshift/tls/tradeshift_ca.cert',
    mode   => '0400',
    owner  => root,
    group  => root,
  } ->
  file { '/etc/docker/certs.d/registry.tradeshift.com/client.cert' :
    ensure => link,
    target => '/etc/tradeshift/tls/client.cert',
    mode   => '0400',
    owner  => root,
    group  => root,
  } ->
  file { '/etc/docker/certs.d/registry.tradeshift.com/client.key' :
    ensure => link,
    target => '/etc/tradeshift/tls/client.key',
    mode   => '0400',
    owner  => root,
    group  => root,
  } ~>
  class { 'docker::service': }
}
