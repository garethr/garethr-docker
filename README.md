Puppet module for installing, configuring and managing
[Docker](https://github.com/dotcloud/docker) from the [official repository](http://docs.docker.io/en/latest/installation/ubuntulinux/) on Ubuntu, from [EPEL on RedHat](http://docs.docker.io/en/latest/installation/rhel/) based distributions or the [standard repositories](http://docs.docker.com/installation/archlinux/) for Archlinux and Fedora.

[![Puppet
Forge](http://img.shields.io/puppetforge/v/garethr/docker.svg)](https://forge.puppetlabs.com/garethr/docker) [![Build
Status](https://secure.travis-ci.org/garethr/garethr-docker.png)](http://travis-ci.org/garethr/garethr-docker) [![Documentation
Status](http://img.shields.io/badge/docs-puppet--strings-lightgrey.svg)](https://garethr.github.io/garethr-docker)

## Support

This module is currently tested on:

* Ubuntu 12.04
* Ubuntu 14.04
* Centos 7.0

It may work on other distros and additional operating systems will be
supported in the future. It's definitely been used with the following
too:

* Centos 6.5
* Archlinux
* Amazon Linux
* Fedora

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

By default the docker daemon will bind to a unix socket at
/var/run/docker.sock. This can be changed, as well as binding to a tcp
socket if required.

```puppet
class { 'docker':
  tcp_bind    => 'tcp://127.0.0.1:4243',
  socket_bind => 'unix:///var/run/docker.sock',
}
```

Unless specified this installs the latest version of docker from the docker inc
repository on first run. However if you want to specify a specific version you
can do so, unless you are using Archlinux which only supports the latest release:

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

### Containers

Now you have an image you can run commands within a container managed by docker.

```puppet
docker::run { 'helloworld':
  image   => 'base',
  command => '/bin/sh -c "while true; do echo hello world; sleep 1; done"',
}
```

This is equivalent to running the following under upstart:

    docker run -d base /bin/sh -c "while true; do echo hello world; sleep 1; done"

Run also contains a number of optional parameters:

```puppet
docker::run { 'helloworld':
  image           => 'base',
  command         => '/bin/sh -c "while true; do echo hello world; sleep 1; done"',
  ports           => ['4444', '4555'],
  expose          => ['4666', '4777'],
  links           => ['mysql:db'],
  use_name        => true,
  volumes         => ['/var/lib/couchdb', '/var/log'],
  volumes_from    => '6446ea52fbc9',
  memory_limit    => 10m, # (format: <number><unit>, where unit = b, k, m or g)
  cpuset          => ['0', '3'],
  username        => 'example',
  hostname        => 'example.com',
  env             => ['FOO=BAR', 'FOO2=BAR2'],
  dns             => ['8.8.8.8', '8.8.4.4'],
  restart_service => true,
  privileged      => false,
  pull_on_start   => false,
  depends         => [ 'container_a', 'postgres' ],
}
```

Ports, expose, env, dns and volumes can be set with either a single string or as above with an array of values.

Specifying `pull_on_start` will pull the image before each time it is started.

The `depends` option allows expressing containers that must be started before. This affects the generation of the init.d/systemd script.

The service file created for systemd and upstart based systems enables automatic restarting of the service on failure by default.

To use an image tag just append the tag name to the image name separated by a semicolon:

```puppet
docker::run { 'helloworld':
  image   => 'ubuntu:precise',
  command => '/bin/sh -c "while true; do echo hello world; sleep 1; done"',
}
```

### Exec

Docker also supports running arbitrary comments within the context of a
running container. And now so does the Puppet module.

```puppet
docker::exec { 'helloworld-uptime':
  detached  => true,
  container => 'helloworld',
  command   => 'uptime',
  tty       => true,
}
```

