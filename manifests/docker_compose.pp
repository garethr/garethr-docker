#docker::docker_compose

class docker::docker_compose {

validate_bool($docker::use_upstream_package_source)
validate_bool($docker::manage_python)


if $::osfamily == 'RedHat' {
  if ($docker::use_upstream_package_source) {
    if $::operatingsystemrelease == '7.0' {
      include epel
      }
    }
  }

if ($docker::manage_python) {
  class { 'python' :
    version    => 'system',
    pip        => true,
    dev        => true,
    virtualenv => false,
    gunicorn   => false,
    }
  }

python::pip { 'docker-compose' :
  ensure  => $docker::docker_compose_version,
  pkgname => 'docker-compose',
  timeout => 1800,
  }

if $::operatingsystem == 'Ubuntu' {
  if $::operatingsystemrelease == '14.04'{
    python::pip { 'requests' :
      ensure  => '2.5.3',
      pkgname => 'requests',
      timeout => 1800,
      }
    }
  }
}