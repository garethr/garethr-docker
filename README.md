Puppet module for installing, configuring and managing
[Docker](https://github.com/docker/docker) from the [official repository](http://docs.docker.com/installation/) or alternatively from [EPEL on RedHat](http://docs.docker.io/en/latest/installation/rhel/) based distributions.
 
[![Puppet
Forge](http://img.shields.io/puppetforge/v/garethr/docker.svg)](https://forge.puppetlabs.com/garethr/docker) [![Build
Status](https://secure.travis-ci.org/garethr/garethr-docker.png)](http://travis-ci.org/garethr/garethr-docker) [![Documentation
Status](http://img.shields.io/badge/docs-puppet--strings-lightgrey.svg)](https://garethr.github.io/garethr-docker) [![Puppet Forge
Downloads](http://img.shields.io/puppetforge/dt/garethr/docker.svg)](https://forge.puppetlabs.com/garethr/docker) [![Puppet Forge
Endorsement](https://img.shields.io/puppetforge/e/garethr/docker.svg)](https://forge.puppetlabs.com/garethr/docker)


## Support

This module is currently tested on:

* Debian 8.0
* Debian 7.8
* Ubuntu 12.04
* Ubuntu 14.04
* Centos 7.0
* Centos 6.6

It may work on other distros and additional operating systems will be
supported in the future. It's definitely been used with the following
too:

* Archlinux
* Amazon Linux
* Fedora

## Examples

* [Launch vNext app in Docker using Puppet](https://github.com/garethr/puppet-docker-vnext-example)
  This example contains a fairly simple example using Vagrant to launch a
  Linux virtual machine, then Puppet to install Docker, build an image and
  run a container. For added spice the container runs a ASP.NET vNext
  application.
* [Multihost containers connected with
  Consul](https://github.com/garethr/puppet-docker-example)
  Launch multiple hosts running simple application containers and
  connect them together using Nginx updated by Consul and Puppet.
* [Configure Docker Swarm using
  Puppet](https://github.com/garethr/puppet-docker-swarm-example)
  Build a cluster of hosts running Docker Swarm configured by Puppet.

## Usage

The module includes a single class:

```puppet
include 'docker'
```

By default this sets up the docker hosted repository if necessary for your OS
and installs the docker package and on Ubuntu, any required Kernel extensions.

If you don't want this module to mess about with your Kernel then you can disable
this feature like so. It is only enabled (and supported) by default on Ubuntu:

```puppet
class { 'docker':
  manage_kernel => false,
}
```

If you want to configure your package sources independently, inform this module
to not auto-include upstream sources (This is already disabled on Archlinux
as there is no further upstream):

```puppet
class { 'docker':
  use_upstream_package_source => false,
}
```

Docker recently [launched new official
repositories](http://blog.docker.com/2015/07/new-apt-and-yum-repos/#comment-247448)
which are now the default for the module from version 5. If you want to
stick with the old respoitories you can do so with the following:

```puppet
class { 'docker':
  package_name => 'lxc-docker',
  package_source_location => 'https://get.docker.com/ubuntu',
  package_key_source => 'https://get.docker.com/gpg',
  package_key => '36A1D7869245C8950F966E92D8576A8BA88D21E',
  package_release => 'docker',
}
```

The module also now uses the upstream repositories by default for RHEL
based distros, including Fedora. If you want to stick with the distro packages
you should use the following:

```puppet
class { 'docker':
  use_upstream_package_source => false,
  package_name => 'docker',
}
```

By default the docker daemon will bind to a unix socket at
/var/run/docker.sock. This can be changed, as well as binding to a tcp
socket if required.

```puppet
class { 'docker':
  tcp_bind    => 'tcp://127.0.0.1:4243',
  socket_bind => 'unix:///var/run/docker.sock',
}
```

Unless specified this installs the latest version of docker from the docker
repository on first run. However if you want to specify a specific version you
can do so, unless you are using Archlinux which only supports the latest release.
Note that this relies on a package with that version existing in the reposiroty.

```puppet
class { 'docker':
  version => '0.5.5',
}
```

And if you want to track the latest version you can do so:

```puppet
class { 'docker':
  version => 'latest',
}
```

In some cases dns resolution won't work well in the container unless you give a dns server to the docker daemon like this:

```puppet
class { 'docker':
  dns => '8.8.8.8',
}
```

To add users to the Docker group you can pass an array like this:

```puppet
class { 'docker':
  docker_users => ['user1', 'user2'],
}
```

The class contains lots of other options, please see the inline code
documentation for the full options.

### Images

The next step is probably to install a docker image; for this we have a defined type which can be used like so:

```puppet
docker::image { 'base': }
```

This is equivalent to running `docker pull base`. This is downloading a large binary so on first run can take a while. For that reason this define turns off the default 5 minute timeout for exec. Takes an optional parameter for installing image tags that is the equivalent to running `docker pull -t="precise" ubuntu`:

```puppet
docker::image { 'ubuntu':
  image_tag => 'precise'
}
```

Note: images will only install if an image of that name does not already exist.

A images can also be added/build from a dockerfile with the `docker_file` property, this equivalent to running `docker build -t ubuntu - < /tmp/Dockerfile`

```puppet
docker::image { 'ubuntu':
  docker_file => '/tmp/Dockerfile'
}
```

Images can also be added/build from a directory containing a dockerfile with the `docker_dir` property, this is equivalent to running `docker build -t ubuntu /tmp/ubuntu_image`

```puppet
docker::image { 'ubuntu':
  docker_dir => '/tmp/ubuntu_image'
}
```

You can also remove images you no longer need with:

```puppet
docker::image { 'base':
  ensure => 'absent'
}

docker::image { 'ubuntu':
  ensure    => 'absent',
  image_tag => 'precise'
}
```

If using hiera, there's a `docker::images` class you can configure, for example:

```yaml
docker::images:
  ubuntu:
    image_tag: 'precise'
```

### Containers

Now you have an image you can launch containers:

```puppet
docker::run { 'helloworld':
  image   => 'base',
  command => '/bin/sh -c "while true; do echo hello world; sleep 1; done"',
}
```

This is equivalent to running the following:

    docker run -d base /bin/sh -c "while true; do echo hello world; sleep 1; done"

This will launch a Docker container managed by the local init system.

Run also takes a number of optional parameters:

```puppet
docker::run { 'helloworld':
  image           => 'base',
  command         => '/bin/sh -c "while true; do echo hello world; sleep 1; done"',
  ports           => ['4444', '4555'],
  expose          => ['4666', '4777'],
  links           => ['mysql:db'],
  volumes         => ['/var/lib/couchdb', '/var/log'],
  volumes_from    => '6446ea52fbc9',
  memory_limit    => '10m', # (format: '<number><unit>', where unit = b, k, m or g)
  cpuset          => ['0', '3'],
  username        => 'example',
  hostname        => 'example.com',
  env             => ['FOO=BAR', 'FOO2=BAR2'],
  env_file        => ['/etc/foo', '/etc/bar'],
  dns             => ['8.8.8.8', '8.8.4.4'],
  restart_service => true,
  privileged      => false,
  pull_on_start   => false,
  before_stop     => 'echo "So Long, and Thanks for All the Fish"',
  depends         => [ 'container_a', 'postgres' ],
}
```

Ports, expose, env, env_file, dns and volumes can be set with either a single string or as above with an array of values.

Specifying `pull_on_start` will pull the image before each time it is started.

Specifying `before_stop` will execute a command before stopping the container.

The `depends` option allows expressing containers that must be started before. This affects the generation of the init.d/systemd script.

The service file created for systemd based systems enables automatic restarting of the service on failure by default.

To use an image tag just append the tag name to the image name separated by a semicolon:

```puppet
docker::run { 'helloworld':
  image   => 'ubuntu:precise',
  command => '/bin/sh -c "while true; do echo hello world; sleep 1; done"',
}
```

If using hiera, there's a `docker::run_instance` class you can configure, for example:

```yaml
---
  classes:
    - docker::run_instance

  docker::run_instance::instance:
    helloworld:
      image: 'ubuntu:precise'
      command: '/bin/sh -c "while true; do echo hello world; sleep 1; done"'
```

###Docker Networking
The following class will set up the native Docker networking in Docker engine 1.9.1 and above. There are 2 functions of the class to create a network, or connect a container to a network. Please note you can't declare both connect and create in the same class. 
Below is an example for creating a network:

```puppet
docker_network { 'my-net':
  ensure => present,
  create => true, 
  driver => 'overlay',
}
``` 
The above example covers the minimum params to create a simple network. For a more advance configuration you can add the following:
```puppet 
docker_network { 'my-net':
  ensure  => present,
  create  => true, 
  driver  => 'overlay',
  subnet  => '192.168.1.0/24',
  gateway => '192.168.1.1',
  iprange => ' 192.168.1.4/32'
}
```
To delete a network use the following:
```puppet
docker_network { 'my-net':
  ensure  => absent }
```
To connect a container that is already running please do the following:
```puppet
docker_network { 'my-net':
  ensure  => present,
  connect => 'example-container'
 } 

``` 

### Private registries
By default images will be pushed and pulled from [index.docker.io](http://index.docker.io) unless you've specified a server. If you have your own private registry without authentication, you can fully qualify your image name. If your private registry requires authentication you may configure a registry:

```puppet
docker::registry { 'example.docker.io:5000':
  username => 'user',
  password => 'secret',
  email    => 'user@example.com',
}
```

You can logout of a registry if it is no longer required.

```puppet
docker::registry { 'example.docker.io:5000':
  ensure => 'absent',
}
```

If using hiera, there's a docker::registry_auth class you can configure, for example:

```yaml
docker::registry_auth::registries:
  'example.docker.io:5000':
    username: 'user1'
    password: 'secret'
    email: 'user1@example.io'
```

### Exec

Docker also supports running arbitrary commands within the context of a
running container. And now so does the Puppet module.

```puppet
docker::exec { 'cron_allow_root':
  detach       => true,
  container    => 'mycontainer',
  command      => '/bin/echo root >> /usr/lib/cron/cron.allow',
  tty          => true,
  unless       => 'grep root /usr/lib/cron/cron.allow 2>/dev/null',
}
```

### Docker-compose

Docker-compose allows you to configure and run multple containers from a single erb file.
If your OS has Python 2.6 please set the docker compose version to 1.2.0 
The Puppet module expects to find the docker-compose.yml file first.
```puppet
file { '/root/docker-compose.yml':
  ensure    => file,
  content   => template('helloworld/docker-compose.yml.erb'), 
  }
```
Then will build the containers with the following statement

```puppet
docker_compose {'Hello World':
  ensure   => present, 
  source   => '/root',  
  scale    => ['1', '3']
  }
```
Source is the directory where the docker-compose.yml lives. This defaults to /tmp if no value is passed
Scale sets the number of conatiner instances of an application. This needs to be passed as an array and will index the againist the conatiner applcation key name in the docker-compose.yml from top to bottom. This defaults to 1 for each application if no value is passed.
For example. If your docker-compose.yml looks like this
````puppet
container1:  
    image: docker/helloworld
    hostname: hello1
    command: '/bin/sh -c "while true; do echo hello world; sleep 1; done"'

container2:  
    image: docker/helloworld
    hostname: hello2
    command: '/bin/sh -c "while true; do echo hello world; sleep 1; done"'

container3:  
    image: docker/helloworld
    hostname: hello3
    command: '/bin/sh -c "while true; do echo hello world; sleep 1; done"'
````
and your scale decleration looks like
````puppet
scale    => ['1', '3', '1']
````
conatiner1 would have 1 instance

conatiner2 would have 3 instances

conatiner3 would have 1 instance
