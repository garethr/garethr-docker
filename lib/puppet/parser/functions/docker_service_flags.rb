require 'shellwords'

module Puppet::Parser::Functions
  # Transforms a hash into a string of docker swarm init flags
  newfunction(:docker_service_flags, :type => :rvalue) do |args|
    opts = args[0] || {}
    flags = []

    if opts['detach'].to_s != 'true'
      flags << '--detach'
    end
    
    if opts['service_name'].to_s != 'undef'
      flags << "'#{opts['service_name']}'"	    
    end

    if opts['env'].to_s != 'undef'
      flags << "--env '#{opts['env']}'"
    end
    
    if opts['label'].to_s != 'undef'
      flags << "--label '#{opts['label']}'"
    end

    if opts['publish'].to_s != 'undef'
      flags << "--publish '#{opts['publish']}'"
    end
    
    if opts['replicas'].to_s != 'undef'
      flags << "--replicas '#{opts['replicas']}'"
    end      

    if opts['tty'].to_s != 'false'
      flags << '--tty'
    end   
    
    if opts['user'].to_s != 'undef'
      flags << "--user '#{opts['publish']}'"
    end   
    
    if opts['workdir'].to_s != 'undef'
      flags << "--workdir '#{opts['workdir']}'"
    end  
    
    if opts['extra_params'].each do |param|
      flags << param
     end
    end
   
    if opts['image'].to_s != 'undef'
      flags << "'#{opts['image']}'"      
    end

    flags.flatten.join(" ")
  end
end
