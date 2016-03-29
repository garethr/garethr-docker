require 'json'

Puppet::Type.type(:docker_network).provide(:ruby) do
  desc "Support for Docker Networking"

  mk_resource_methods
  commands :docker => 'docker'

	def network_conf
		flags = ['network', 'create']
		multi_flags = lambda { |values, format|
      filtered = [values].flatten.compact
      filtered.map { |val| sprintf(format, val) }
    }

    [
      ['--driver=%s',       :driver],
      ['--subnet=%s',       :subnet],
      ['--gateway=%s',      :gateway],
      ['--ip-range=%s',     :ip_range],
      ['--ipam-driver=%s',  :ipam_driver],
      ['--aux-address=%s',  :aux_address],
      ['--opt=%s',          :options],
    ].each do |(format, key)|
      values    = resource[key]
      new_flags = multi_flags.call(values, format)
      flags.concat(new_flags)
    end
		flags << resource[:name]
	end

	def self.instances
		output = docker(['network', 'ls'])
		lines = output.split("\n")
		lines.shift # remove header row
		lines.collect do |line|
			_, name, driver = line.split(' ')
			inspect = docker(['network', 'inspect', name])
			obj = JSON.parse(inspect).first
			subnet = unless obj['IPAM']['Config'].empty?
				if obj['IPAM']['Config'].first.key? 'Subnet'
					obj['IPAM']['Config'].first['Subnet']
				end
			end
			new({
				:name => name,
				:id => obj['Id'],
				:ipam_driver => obj['IPAM']['Driver'],
				:subnet => subnet,
				:ensure => :present,
				:driver => driver,
			})
		end
	end

	def self.prefetch(resources)
    instances.each do |prov|
      if resource = resources[prov.name] # rubocop:disable Lint/AssignmentInCondition
        resource.provider = prov
      end
    end
	end

  def flush
    if ! @property_hash.empty? and @property_hash[:ensure] != :absent
      fail 'Docker network does not support mutating existing networks'
    end
  end

  def exists?
  	Puppet.info("Checking if docker network #{name} exists")
		@property_hash[:ensure] == :present
  end

	def create
  	Puppet.info("Creating docker network #{name}")
		docker(network_conf)
 	end

  def destroy
  	Puppet.info("Removing docker network #{name}")
		docker(['network', 'rm', name])
  end
end
