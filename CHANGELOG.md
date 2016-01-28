##2016-01-28 - Version 5.1

This release includes a few minor bug-fixes along with three new
features:

* The module now allows for installing, and running, Docker Compose from
  Puppet, using both the docker::compose class the the docker_compose
  type.
* The module also now allows for the creation and management of Docker
  Network using the new docker_network type
* And the docker::run type now supports ensure => absent

Fixes include:

* Ensuring idempotence of docker::run using deprecated params
* Properly escaping variables in unless for docker::exec
* Explicitly specify systemd as the service provider for recent versions
  of Ubuntu and Debian

##2015-12-18 - Version 5.0

Note that this is a major release and in particular changes the default
repository behaviour so all supported operating systems use the new
Docker upstream repos.

This release includes:

* Full docker label support
* Support for CentOS 7 repository options
* Support for Docker's built-in restart policy
* Docker storage setup options support for systemd
* The ability to configure log drivers
* Support unless for docker exec
* Full datamapper property support, and deprecation of old property
  names
* Allow arbitrary parameters to be passed to systemd
* Add ZFS storage driver support
* Allow docker image resources to be refreshed, pulling the latest
* Deprecates use_name, all containers are now named for the resource
* Support for Puppet 4.3 with the stricter parser


As well as fixes for:

* Fix running=false to not start the docker image on docker restart
  under systemd
* Prevent timeouts for docker run
* Ensure docker is running before attempting to use docker run
* Obsfucate registry password from Puppet logs
