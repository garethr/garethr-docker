require 'beaker-rspec/spec_helper'
require 'beaker-rspec/helpers/serverspec'
require 'pry'
require 'beaker/puppet_install_helper'
require 'rspec/retry'

run_puppet_install_helper unless ENV['BEAKER_provision'] == 'no'

RSpec.configure do |c|
  # Project root
  proj_root = File.expand_path(File.join(File.dirname(__FILE__), '..'))

  # Readable test descriptions
  c.formatter = :documentation

  # show retry status in spec process
  c.verbose_retry = true
  # show exception that triggers a retry if verbose_retry is set to true
  c.display_try_failure_messages = true

  # Configure all nodes in nodeset
  c.before :suite do
    # Install module and dependencies
    puppet_module_install(:source => proj_root, :module_name => 'docker')
    hosts.each do |host|
      on host, shell('sudo yum update -y -q', :pty=>true) if fact_on(host, 'osfamily') == 'RedHat'

      on host, puppet('module', 'install', 'puppetlabs-stdlib'), { :acceptable_exit_codes => [0,1] }
      on host, puppet('module', 'install', 'puppetlabs-apt', '--version', '2.1.0'), { :acceptable_exit_codes => [0,1] }
      on host, puppet('module', 'install', 'stahnma-epel'), { :acceptable_exit_codes => [0,1] }

      # net-tools required for netstat utility being used by some tests
      pp = <<-EOS
        package { 'net-tools': ensure => installed }
      EOS
      if fact_on(host, 'osfamily') == 'RedHat' && fact_on(host, 'operatingsystemmajrelease') == '7'
        on host, apply_manifest(pp), { :catch_failures => false }
      end

      docker_compose_content = <<-EOS
compose_test:
  image: ubuntu:14.04
  command: /bin/sh -c "while true; do echo hello world; sleep 1; done"
      EOS
      create_remote_file(host, "/tmp/docker-compose.yml", docker_compose_content)
    end
  end
end
