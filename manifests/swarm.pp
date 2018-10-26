# == Define: docker_old::swarm
# 
# A define that managers a Docker Swarm Mode cluster
#
# == Paramaters
#
# [*ensure*] 
#  This ensures that the cluster is present or not.
#  Defaults to present
#  Note this forcefully removes a node from the cluster. Make sure all worker nodes
#  have been removed before managers
#
# [*init*]
#  This creates the first worker node for a new cluster.
#  Set init to true to create a new cluster
#  Defaults to false  
#
# [*join*]
#  This adds either a worker or manger node to the cluster.
#  The role of the node is defined by the join token.
#  Set to true to join the cluster
#  Defaults to false
#
# [*advertise_addr*]
#  The address that your node will advertise to the cluster for raft.
#  On multihomed servers this flag must be passed
#  Defaults to undef
#
# [*autolock*]
#   Enable manager autolocking (requiring an unlock key to start a stopped manager)
#   Defaults to undef
#
# [*cert_expiry*]
#  Validity period for node certificates (ns|us|ms|s|m|h) (default 2160h0m0s)
#  defaults to undef
#  
# [*dispatcher_heartbeat*]
#  Dispatcher heartbeat period (ns|us|ms|s|m|h) (default 5s)
#  Defaults to undef
#
# [*external_ca*]
#  Specifications of one or more certificate signing endpoints
#  Defaults to undef
#
# [*force_new_cluster*]
#  Force create a new cluster from current state
#  Defaults to false
#
# [*listen_addr*]
#  The address that your node will listen to the cluster for raft.
#  On multihomed servers this flag must be passed
#  Defaults to undef
#
# [*max_snapshots*]
#  Number of additional Raft snapshots to retain
#  Defaults to undef
#
# [*snapshot_interval*]
#  Number of log entries between Raft snapshots (default 10000)
#  Defaults to undef
#
# [*token*]
#  The authentication token to join the cluster. The token also defines the type of
#  node (worker or manager)
#  Defaults to undef
#
# [*manager_ip*]
#  The ip address of a manager node to join the cluster.
#  Defaults to undef
#


define docker_old::swarm(

  $ensure = 'present',
  $init = false,
  $join = false,
  $advertise_addr = undef,
  $autolock = false,
  $cert_expiry = undef,
  $dispatcher_heartbeat = undef,
  $external_ca = undef,
  $force_new_cluster = false,
  $listen_addr = undef,
  $max_snapshots = undef,
  $snapshot_interval = undef,
  $token = undef,
  $manager_ip = undef,
  ){

  include docker_old::params

  $docker_command = "${docker::params::docker_command} swarm"
  validate_re($ensure, '^(present|absent)$')
  validate_string($docker_command)
  validate_string($cert_expiry)
  validate_string($dispatcher_heartbeat)
  validate_string($external_ca)
  validate_string($max_snapshots)
  validate_string($snapshot_interval)
  validate_string($token)
  validate_ip_address($advertise_addr)
  validate_ip_address($listen_addr)
  validate_bool($init)
  validate_bool($join)
  validate_bool($autolock)
  validate_bool($force_new_cluster)

  if $init {
  $docker_swarm_init_flags = docker_swarm_init_flags({
    init => $init,
    advertise_addr => $advertise_addr,
    autolock => $autolock,
    cert_expiry => $cert_expiry,
    dispatcher_heartbeat => $dispatcher_heartbeat,
    external_ca => $external_ca,
    force_new_cluster => $force_new_cluster,
    listen_addr => $listen_addr,
    max_snapshots => $max_snapshots,
    snapshot_interval => $snapshot_interval,
    })

  $exec_init = "${docker_command} ${docker_swarm_init_flags}"
  $unless_init = 'docker info | grep -w "Swarm: active"'

  exec { 'Swarm init':
    command     => $exec_init,
    environment => 'HOME=/root',
    path        => ['/bin', '/usr/bin'],
    timeout     => 0,
    unless      => $unless_init,
    }
  }

  if $join {
  $docker_swarm_join_flags = docker_swarm_join_flags({
    join => $join,
    advertise_addr => $advertise_addr,
    listen_addr => $listen_addr,
    token => $token,
    })

  $exec_join = "${docker_command} ${docker_swarm_join_flags} ${manager_ip}"
  $unless_join = 'docker info | grep -w "Swarm: active"'

  exec { 'Swarm join':
    command     => $exec_join,
    environment => 'HOME=/root',
    path        => ['/bin', '/usr/bin'],
    timeout     => 0,
    unless      => $unless_join,
    }
  }

  if $ensure == 'absent' {
    exec { 'Leave swarm':
      command => 'docker swarm leave --force',
      onlyif  => 'docker info | grep -w "Swarm: active"',
      path    => ['/bin', '/usr/bin'],
    }
  }
}
