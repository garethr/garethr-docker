Puppet module for installing
[Docker](https://github.com/dotcloud/docker) from the [official PPA](https://launchpad.net/~dotcloud/+archive/lxc-docker).

This module is also available on the [Puppet
Forge](https://forge.puppetlabs.com/garethr/docker)

[![Build
Status](https://secure.travis-ci.org/garethr/garethr-docker.png)](http://travis-ci.org/garethr/garethr-docker)

## Usage

The module includes a single class:

    include 'docker'

By default this sets up the PPA and installs the lxc-docker package.

### Images

The next step is probably to install a docker image, for this we have a
defined type which can be used like so:

    docker::image { 'base': }

This is equivalent to running `docker pull base`. Note that it will run
only if the image of that name does not already exist. This is
downloading a large binary so on first run can take a while. For that
reason this define turns off the default 5 minute timeout for exec. Note
that you can also remove images you no longer need with:

    docker::image { 'base':
      ensure => 'absent',
    }

### Containers

Now you have an image you can run commands within a container managed by
docker.

    docker::run { 'helloworld':
      image   => 'base',
      command => '/bin/sh -c "while true; do echo hello world; sleep 1; done"',
    }

This is equivalent to running the following under upstart:

    docker run -d base /bin/sh -c "while true; do echo hello world; sleep 1; done"

Run also contains a number of optional parameters:

    docker::run { 'helloworld':
      image        => 'base',
      command      => '/bin/sh -c "while true; do echo hello world; sleep 1; done"',
      ports        => ['4444', '4555'],
      volumes      => ['/var/lib/counchdb', '/var/log'],
      volumes_from => '6446ea52fbc9',
      memory_limit => 10485760, # bytes 
      username     => 'example',
      hostname     => 'example.com',
      env          => ['FOO=BAR', 'FOO2=BAR2'],
      dns          => ['8.8.8.8', '8.8.4.4'],
    }

Note that ports, env, dns and volumes can be set with either a single string
or as above with an array of values.
