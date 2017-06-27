Puppet::Type.type(:docker_stack).provide(:docker_stack) do
  desc 'Support for Puppet running Docker Stack.'

  mk_resource_methods
  commands :docker => '/usr/bin/docker'

  def exists?
    Puppet.info("Checking services for compose project #{resource[:namestack]}")
    compose_file = YAML.load(File.read(resource[:path]))
    services = `/usr/bin/docker stack ls | /bin/grep #{resource[:namestack]} | /usr/bin/awk -F " " '{print $2}'`.to_i
    count=0
    case compose_file["version"]
    when /^3(\.\d{1,})?$/
      Puppet.info("Checking the services in the stack #{resource[:namestack]}")
      compose_file["services"].each_key.collect { |key|
        count += 1
      }
    else
      raise(Puppet::Error, "Unsupported docker compose file syntax version \"#{compose_file["version"]}\"!")
    end
    if (services == count) then
      true
    else
      false
    end
  end

  def create
    Puppet.info("Running compose project #{resource[:namestack]}")
    args = ['stack', 'deploy', '-c', resource[:path], resource[:namestack]].compact
    docker(args)
  end

  def destroy
    Puppet.info("Removing all containers for stack project #{resource[:namestack]}")
    kill_args = ['stack', 'rm', resource[:namestack]].compact
    docker(kill_args)
  end

  def redeploy
    if exists?
      Puppet.info("Redeploy compose project #{resource[:namestack]}")
      args = ['stack', 'up', '-c', resource[:path], resource[:namestack]].compact
      docker(args)
    end
  end

end
