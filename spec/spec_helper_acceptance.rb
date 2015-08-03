require 'beaker-rspec/spec_helper'
require 'beaker-rspec/helpers/serverspec'
require 'pry'
require 'beaker/puppet_install_helper'

run_puppet_install_helper unless ENV['BEAKER_provision'] == 'no'

RSpec.configure do |c|
  # Project root
  proj_root = File.expand_path(File.join(File.dirname(__FILE__), '..'))

  # Readable test descriptions
  c.formatter = :documentation

  # Configure all nodes in nodeset
  c.before :suite do
    # Install module and dependencies
    puppet_module_install(:source => proj_root, :module_name => 'docker')
    hosts.each do |host|
      on host, puppet('module', 'install', 'puppetlabs-stdlib'), { :acceptable_exit_codes => [0,1] }
      on host, puppet('module', 'install', 'puppetlabs-apt', '--version', '2.1.0'), { :acceptable_exit_codes => [0,1] }
      on host, puppet('module', 'install', 'stahnma-epel'), { :acceptable_exit_codes => [0,1] }

      # net-tools required for netstat utility being used by some tests
      pp = <<-EOS
        package { 'net-tools': ensure => installed }
      EOS
      if fact_on(host, 'osfamily')== 'RedHat' && fact_on(host, 'operatingsystemmajrelease') == '7'
        on host, apply_manifest(pp), { :catch_failures => false }
      end
    end
  end
end
