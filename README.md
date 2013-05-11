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

The next step is probably to install a docker image, for this we have a
defined type which can be used like so:

    docker::pull { 'base': }

This is equivalent to running `docker pull base`. Note that it will run
only if the image of that name does not already exist. This is
downloading a large binary so on first run can take a while. For that
reason this define turns off the default 5 minute timeou for exec.
