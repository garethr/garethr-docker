# docker::images
class docker::compose {

  exec{'Install composer':
    path => '/usr/bin/',
    cwd  => '/tmp',
    command => 'curl -L https://github.com/docker/compose/releases/download/1.5.2/docker-compose-`uname -s`-`uname -m` > /usr/local/bin/docker-compose',
    creates => '/usr/local/bin/docker-compose'
  }->
  file{'/usr/local/bin/docker-compose':
    owner => 'root',
    mode => '0766'
  }


}
