Puppet::Type.newtype(:docker_stack) do

  @doc=%q{Manage Docker stacks in compose v3.

    Example:

      docker_stack { '/root/docker-compose.yml':
        ensure    => present,
        namestack => 'test',
      }
  }

  ensurable

  newparam(:namestack) do
    desc 'Name of the Docker Stack.'
  end

  newparam(:path, :namevar => true) do
    desc 'Absolute path of docker-compose.yml.'
    validate do |value|
      unless Puppet::Util.absolute_path?(value)
        raise Puppet::Error, "File paths must be fully qualified, not '#{value}'"
      end
    end
  end

  def refresh
    provider.redeploy
  end

  autorequire(:file) do
    self[:path]
  end

  validate do
    unless self[:path]
      raise(Puppet::Error, "path is a required attribute")
    end
  end

end
