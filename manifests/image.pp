# == Class: docker
#
# Module to install an up-to-date version of a Docker image
# from the registry
#
# === Parameters
# [*ensure*]
#   Whether you want the image present or absent.
#
# [*image*]
#   If you want the name of the image to be different from the
#   name of the puppet resource you can pass a value here.
#
# [*image_tag*]
#   If you want a specific tag of the image to be installed
#
# [*docker_file*]
#   If you want to add a docker image from specific docker file
#
# [*docker_tar*]
#   If you want to load a docker image from specific docker tar
#

define docker::image(
  $ensure    = 'present',
  $image     = $title,
  $image_tag = undef,
  $force     = false,
  $docker_file = undef,
  $docker_dir = undef,
  $docker_tar = undef,
) {
  include docker::params
  $docker_command = $docker::params::docker_command

  validate_re($ensure, '^(present|absent|latest)$')
  validate_re($image, '^[\S]*$')
  validate_bool($force)

  if ($docker_file) and ($docker_dir) {
    fail 'docker::image must not have both $docker_file and $docker_dir set'
  }

  if ($docker_file) and ($docker_tar) {
    fail 'docker::image must not have both $docker_file and $docker_tar set'
  }

  if ($docker_dir) and ($docker_tar) {
    fail 'docker::image must not have both $docker_dir and $docker_tar set'
  }

  if $force {
    $image_force   = '-f '
  } else {
    $image_force   = ''
  }

  if $::osfamily == 'windows' {
    $all_users_profile = $docker::params::all_users_profile
    $docker_expanded_command = $docker::params::docker_expanded_command

    # Wrapper used to ensure images are up to date
    ensure_resource('file', "${all_users_profile}\\Docker\\update_docker_image.ps1",
      {
        ensure  => $docker::params::ensure,
        content => template('docker/update_docker_image.ps1.erb'),
      }
    )

    if $image_tag {
      $image_arg     = "${image}:${image_tag}"
      $image_remove  = "${docker_command} rmi ${image_force}${image}:${image_tag}"
      $image_find    = "${docker_command} images | Select-String -Pattern '^(docker\\.io/)?${image}\\b' | 
                     Foreach {\"\$((\$_ -split '\\s+',4)[1])\"} | Select-String -Quiet -Pattern '^${image_tag}\$'"
    } else {
      $image_arg     = $image
      $image_remove  = "${docker_command} rmi ${image_force}${image}"
      $image_find    = "${docker_command} images | ForEach { \$_.split(' ')[0] } | 
                     Select-String -Quiet -Pattern '^(docker\\.io/)?${image}\$'"
    }

    if $docker_dir {
      $image_install = "${docker_command} build -t ${image_arg} \"${docker_dir}\""
    } elsif $docker_file {
      $image_install = "Get-Content \"${docker_file}\" | ${docker_command} build -t \"${image_arg}\" - "
    } elsif $docker_tar {
      $image_install = "${docker_command} load -i \"${docker_tar}\""
    } else {
      $image_install = "${all_users_profile}\\Docker\\update_docker_image.ps1 ${image_arg}"
    }

    $image_path = [$::docker_binpath]
    $image_provider = 'powershell'
    $image_conditional = "if(${image_find}) {exit 0} else {exit 1}"
    $image_reqfile = "${all_users_profile}\\Docker\\update_docker_image.ps1"
    $image_logoutput = true
    $image_environment = 'HOME=C:\\'
    $image_absent_command = $image_remove
    $image_latest_command = "Write-Output 'Update of ${image_arg}' complete"
    $image_present_command = $image_install

  } else {
    # Wrapper used to ensure images are up to date
    ensure_resource('file', '/usr/local/bin/update_docker_image.sh',
      {
        ensure  => $docker::params::ensure,
        owner   => 'root',
        group   => 'root',
        mode    => '0555',
        content => template('docker/update_docker_image.sh.erb'),
      }
    )

    if $image_tag {
      $image_arg     = "${image}:${image_tag}"
      $image_remove  = "${docker_command} rmi ${image_force}${image}:${image_tag}"
      $image_find    = "${docker_command} images | egrep '^(docker.io/)?${image} ' | awk '{ print \$2 }' | grep ^${image_tag}$"
    } else {
      $image_arg     = $image
      $image_remove  = "${docker_command} rmi ${image_force}${image}"
      $image_find    = "${docker_command} images | cut -d ' ' -f 1 | egrep '^(docker\\.io/)?${image}$'"
    }

    if $docker_dir {
      $image_install = "${docker_command} build -t ${image_arg} ${docker_dir}"
    } elsif $docker_file {
      $image_install = "${docker_command} build -t ${image_arg} - < ${docker_file}"
    } elsif $docker_tar {
      $image_install = "${docker_command} load -i ${docker_tar}"
    } else {
      $image_install = "/usr/local/bin/update_docker_image.sh ${image_arg}"
    }

    $image_path = ['/bin', '/usr/bin']
    $image_provider = undef
    $image_conditional = $image_find
    $image_reqfile = '/usr/local/bin/update_docker_image.sh'
    $image_logoutput = undef
    $image_environment = 'HOME=/root'
    $image_absent_command = undef
    $image_latest_command = undef
    $image_present_command = undef
  }

  if $ensure == 'absent' {
    exec { $image_remove:
      path        => $image_path,
      environment => $image_environment,
      provider    => $image_provider,
      command     => $image_absent_command,
      onlyif      => $image_conditional,
      logoutput   => $image_logoutput,
      timeout     => 0,
    }
  } elsif $ensure == 'latest' {
    exec { "echo 'Update of ${image_arg} complete'":
      path        => $image_path,
      environment => $image_environment,
      provider    => $image_provider,
      command     => $image_latest_command,
      onlyif      => $image_install,
      logoutput   => $image_logoutput,
      timeout     => 0,
      require     => File[$image_reqfile],
    }
  } elsif $ensure == 'present' {
    exec { $image_install:
      path        => $image_path,
      environment => $image_environment,
      provider    => $image_provider,
      command     => $image_present_command,
      unless      => $image_conditional,
      logoutput   => $image_logoutput,
      timeout     => 0,
      returns     => ['0','1'],
      require     => File[$image_reqfile],
    }
  }
}
