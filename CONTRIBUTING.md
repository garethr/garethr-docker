This module has grown over time based on a range of contributions from
people using it. If you follow these contributing guidelines your patch
will likely make it into a release a little quicker.


## Contributing

1. Fork the repo.

2. Run the tests. We only take pull requests with passing tests, and
   it's great to know that you have a clean slate

3. Add a test for your change. Only refactoring and documentation
   changes require no new tests. If you are adding functionality
   or fixing a bug, please add a test.

4. Make the test pass.

5. Push to your fork and submit a pull request.


## Dependencies

The testing and development tools have a bunch of dependencies,
all managed by [bundler](http://bundler.io/) according to the
[Puppet support matrix](http://docs.puppetlabs.com/guides/platforms.html#ruby-versions).
By default the tests use a baseline version of Puppet.

If you have Ruby 2.x or want a specific version of Puppet,
you must set an environment variable such as:

    export PUPPET_VERSION="~> 3.2.0"

Install the dependencies like so...

    bundle install

...or promote reuse of bundled gems across projects by running:

    bundle install --path=~/.bundle

## Syntax and style

The test suite will run [Puppet Lint](http://puppet-lint.com/) and
[Puppet Syntax](https://github.com/gds-operations/puppet-syntax) to
check various syntax and style things. You can run these locally with:

    bundle exec rake lint
    bundle exec rake syntax

## Running the unit tests

The unit test suite covers most of the code, as mentioned above please
add tests if you're adding new functionality. If you've not used
[rspec-puppet](http://rspec-puppet.com/) before then feel free to ask
about how best to test your new feature. Running the test suite is done
with:

    bundle exec rake spec

Note also you can run the syntax, style and unit tests in one go with:

    bundle exec rake test

## Integration tests

The unit tests just check the code runs, not that it does exactly what
we want on a real machine. For that we're using
[Beaker](https://github.com/puppetlabs/beaker).
This fires up a new virtual machine (using vagrant) and runs a series of
simple tests against it after applying the module. You can run this
with:

    bundle exec rake beaker

This will run the tests on an Ubuntu 12.04 virtual machine. You can also
run the integration tests against Centos 6.5 with:

    BEAKER_set=centos-64-x64 bundle exec rake beaker

Or with Ubuntu 14.04 with:

    BEAKER_set=ubuntu-server-1404-x64 bundle exec rake beaker

