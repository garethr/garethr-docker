# == Define: docker::services
# 
# A define that managers a Docker services 
#
# == Paramaters
#
# [*ensure*] 
#  This ensures that the service is present or not.
#  Defaults to present
#
# [*image*] 
#  The Docker image to spwan the service from. 
#  Defualts to undef  
#
# [*detach*] 
#  Exit immediately instead of waiting for the service to converge (default true)
#  Defaults to true
#
# [*env*]
#  Set environment variables
#  Defaults to undef
#
# [*label*]
#  Service labels.
#  This used as metdata to configure constraints etc.
#  Defaults to undef
#
# [*publish*]
#  Publish a port as a node port.
#  Defaults to undef
#
# [*replicas*]
#  Number of tasks (containers per service) 
#  defaults to undef
#  
# [*tty*]
#  Allocate a pseudo-TTY
#  Defaults to false
#
# [*user*]
#  Username or UID (format: <name|uid>[:<group|gid>])
#  Defaults to undef
#
# [*workdir*]
#  Working directory inside the container
#  Defaults to false
#
# [*extra_params*]
#  Allows you to pass any other flag that the Docker service create supports.
#  This must be passed as an array. See docker service create --help for all options
#  defaults to []
#
# [*update*]
#  This changes the docker command to 
#  docker service update, you must pass a service name with this option 
#
# [*scale*]
#  This changes the docker command to
#  docker service scale, this can only be used with service name and 
#  replicas
#  

define docker::services(

  $ensure = 'present',
  $image = undef,
  $detach = true,
  $env = undef,
  $service_name = undef,
  $label = undef,
  $publish = undef,
  $replicas = undef,
  $tty = false,
  $user = undef,
  $workdir = undef,
  $extra_params = [],
  $create = true,
  $update = false,
  $scale = false,
  ){

  include docker::params

  $docker_command = "${docker::params::docker_command} service"
  validate_re($ensure, '^(present|absent)$')
  validate_string($docker_command)
  validate_string($image)
  validate_string($env)
  validate_string($service_name)
  validate_string($label)
  validate_string($publish)
  validate_string($replicas)
  validate_string($user)
  validate_string($workdir)
  validate_bool($detach)
  validate_bool($tty)
  validate_bool($create)
  validate_bool($update)
  validate_bool($scale)

  if $ensure == 'absent' {
    if $update {
      fail('When removing a service you can not update it.')
    }
    if $scale {
      fail('When removing a service you can not update it.')
    }
  }

  if $create {
  $docker_service_create_flags = docker_service_flags({
    detach => $detach,
    env => $env,
    service_name => $service_name,
    label => $label,
    publish => $publish,
    replicas => $replicas,
    tty => $tty,
    user => $user,
    workdir => $workdir,
    extra_params => any2array($extra_params),
    image => $image,
    })

  $exec_create = "${docker_command} create --name ${docker_service_create_flags}"
  $unless_create = "docker service ls | grep -w ${service_name}"

  exec { 'Docker service create':
    command     => $exec_create,
    environment => 'HOME=/root',
    path        => ['/bin', '/usr/bin'],
    timeout     => 0,
    unless      => $unless_create,
    }
  }

  if $update {
  $docker_service_flags = docker_service_flags({
    detach => $detach,
    env => $env,
    service_name => $service_name,
    label => $label,
    publish => $publish,
    replicas => $replicas,
    tty => $tty,
    user => $user,
    workdir => $workdir,
    extra_params => any2array($extra_params),
    image => $image,
    })

  $exec_update = "${docker_command} update ${docker_service_flags}"

  exec { 'Docker service update':
    command     => $exec_update,
    environment => 'HOME=/root',
    path        => ['/bin', '/usr/bin'],
    timeout     => 0,
    }
  }

  if $scale {
  $docker_service_flags = docker_service_flags({
    service_name => $service_name,
    replicas => $replicas,
    extra_params => any2array($extra_params),
    })

  $exec_scale = "${docker_command} scale ${docker_service_flags}"

  exec { 'Docker service scale':
    command     => $exec_scale,
    environment => 'HOME=/root',
    path        => ['/bin', '/usr/bin'],
    timeout     => 0,
    }
  }

  if $ensure == 'absent' {
    exec { 'Remove service':
      command => "docker service rm ${service_name}",
      onlyif  => "docker service ls | grep -w ${service_name}",
      path    => ['/bin', '/usr/bin'],
    }
  }
}
