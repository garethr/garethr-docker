require 'shellwords'

module Puppet::Parser::Functions
  # Transforms a hash into a string of docker exec flags
  newfunction(:docker_exec_flags, :type => :rvalue) do |args|
    opts = args[0] || {}
    flags = []

    if opts['detach']
      flags << '--detach=true'
    end

    if opts['interactive']
      flags << '--interactive=true'
    end

    if opts['tty']
      flags << '--tty=true'
    end

    flags.flatten.join(" ")
  end
end
