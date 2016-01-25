Puppet::Type.type(:docker_compose).provide(:ruby) do
  desc 'Support for Puppet running Docker Compose'

  mk_resource_methods
  commands :dockercompose => 'docker-compose'
  commands :docker => 'docker'

  def exists?
    Puppet.info("Checking for compose project #{project}")
    compose_file = YAML.load(File.read(name))
    containers = docker([
      'ps',
      '--format',
      "{{.Label \"com.docker.compose.service\"}}",
      '--filter',
      "label=com.docker.compose.project=#{project}"
    ]).split("\n")
    counts = Hash[*compose_file.each_key.collect { |key|
      Puppet.info("Checking for compose service #{key}")
      [key, containers.count(key)]
    }.flatten]
    # No containers found for the project
    if counts.empty? or
      # Containers described in the compose file are not running
      counts.any? { |k,v| v == 0 } or
      # The scaling factors in the resource do not match the number of running containers
      resource[:scale] && counts.merge(resource[:scale]) != counts
        false
    else
      true
    end
  end

  def create
    Puppet.info("Running compose project #{project}")
    args = ['-f', name, 'up', '-d'].insert(2, resource[:options]).compact
    dockercompose(args)
    if resource[:scale]
      instructions = resource[:scale].collect { |k,v| "#{k}=#{v}" }
      Puppet.info("Scaling compose project #{project}: #{instructions.join(' ')}")
      args = ['-f', name, 'scale'].insert(2, resource[:options]).compact + instructions
      dockercompose(args)
    end
  end

  def destroy
    Puppet.info("Removing all containers for compose project #{project}")
    kill_args = ['-f', name, 'kill'].insert(2, resource[:options]).compact
    dockercompose(kill_args)
    rm_args = ['-f', name, 'rm', '--force', '-v'].insert(2, resource[:options]).compact
    dockercompose(rm_args)
  end

  private
  def project
    File.basename(File.dirname(name)).downcase.gsub(/[^0-9a-z ]/i, '')
  end
end
