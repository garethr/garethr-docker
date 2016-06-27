# == Class: docker
#
# Module to configure swarm mode (docker 1.12 and above)
#
# === Parameters
# [*ensure*]
#   server, manager, worker, leave (worker default)
#
# [*listen_addr*]
#   Listen address (default 0.0.0.0:2377)
#
# [*secret*]
#   Set secret value needed to accept/join node into cluster
#
# [accept_policy]
#  Acceptance policy worker,manager (server only)
#
# [*force_new_cluster*]
#   Force create a new cluster from current state  (server only)
#
# [*join_manager*]
# Join Swarm cluster as manager as a node and/or manager.
#
# [*local_user*]
#   The local user to log in as. Docker will store credentials in this
#   users home directory
#
class docker::swarm(
  $ensure            = 'worker',
  $listen_addr       = undef,
  $join_manager      = undef,
  $secret            = undef,
  $force_new_cluster = undef,
  $accept_policy     = undef,
  $local_user        = 'root',
) {
  include docker::params

  validate_re($ensure, '^(present|absent|server|manager|worker|leave)$')

  $docker_cmd = "${docker::params::docker_command} swarm"
  $exist_flag = "${docker::params::data_folder}/swarm/state.json"

  if $ensure == 'worker' or $ensure == 'manager' or $ensure == 'present' {
    validate_string($join_manager)
  }

  if $listen_addr {
    validate_string($listen_addr)
  }

  if $ensure == 'server' and $accept_policy {
    validate_string($accept_policy)
  }

  if $secret {
    validate_string($secret)
  }

  $listen_tpl = '<% if @listen_addr %> --listen_addr <%= @listen_addr %><% end -%>'
  $secret_tpl = '<% if @secret %> --secret <%= @secret %><% end -%>'

  if $ensure == 'server' {
    $accept_policy_tpl = '<% if @accept_policy %> --auto-accept <%= @accept_policy %><% end -%>'
    $force_new_tpl = '<% if @force_new_cluster %> --force-new-cluster <% end -%>'

    $auth_cmd = inline_template('<%= @docker_cmd %> init', $listen_tpl, $secret_tpl, $accept_policy_tpl, $force_new_tpl)

  } elsif $ensure == 'absent' or $ensure == 'leave' {
    $auth_cmd = "${docker_cmd} leave"
  } else {
    $manager_tpl = '<% if @ensure == "manager" %> --manager <% end -%>'

    $auth_cmd = inline_template('<%= @docker_cmd %> join', $listen_tpl, $secret_tpl, $manager_tpl, '<%= @join_manager %>')
  }

  if $ensure == 'absent' or $ensure == 'leave' {
    exec { "swarm_mode_${ensure}":
      command => $auth_cmd,
      user    => $local_user,
      cwd     => '/root',
      path    => ['/bin', '/usr/bin'],
      timeout => 0,
      onlyif  => $exist_flag,
    }
  } else {
    exec { "swarm_mode_${ensure}":
      command => $auth_cmd,
      user    => $local_user,
      cwd     => '/root',
      path    => ['/bin', '/usr/bin'],
      timeout => 0,
      creates => $exist_flag,
    }
  }
}
