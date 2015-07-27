
# Fact: docker_running_container
#
# Purpose: 
#   Get the number of running containers
#
# Resolution:
#   Use docker ps to obtain the number of running containers.
#
# Caveats:
#   The user used by Puppet to execute this fact must have the rights to call the 'docker' command.
#
Facter.add(:docker_running_container) do
  setcode do
    docker_ps_raw = Facter::Util::Resolution.exec('docker ps | wc -l')
    docker_running_container = docker_ps_raw.to_i - 1
  end
end
