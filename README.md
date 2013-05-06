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
