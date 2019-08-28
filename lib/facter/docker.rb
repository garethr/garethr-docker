require 'facter'
require 'json'

def interfaces
  Facter.value(:interfaces).split(',')
end

Facter.add(:docker) do
  setcode do
    if Facter::Util::Resolution.which('docker')
      docker = Hash.new
      docker['network'] = Hash.new
      docker['network']['managed_interfaces'] = Hash.new
      network_list = Facter::Util::Resolution.exec('docker network ls | tail -n +2')
      docker_network_names = Array.new
      network_list.each_line {|line| docker_network_names.push line.split[1] }
      docker_network_ids = Array.new
      network_list.each_line {|line| docker_network_ids.push line.split[0] }
      docker_network_names.each do |network|
        inspect = JSON.parse(Facter::Util::Resolution.exec("docker network inspect #{network}"))
        docker['network'][network] = inspect[0]
        network_id = docker['network'][network]['Id'][0..11]
        interfaces.each do |iface|
          docker['network']['managed_interfaces'][iface] = network if iface =~ /#{network_id}/
        end
      end
      docker
    end
  end
end
