require 'json'

def docker_bin
  docker_cmd = nil
  possible_values = ['/usr/local/bin/docker', '/usr/bin/docker']
  possible_values.each do |cmd|
    docker_cmd = cmd if File.executable? cmd
  end
  docker_cmd
end

Facter.add(:docker_client_version) do
  setcode do
    docker_version = Facter.value(:docker_version)
    docker_version['Client']['Version'] if docker_version
  end
end

Facter.add(:docker_server_version) do
  setcode do
    docker_version = Facter.value(:docker_version)
    docker_version['Server']['Version'] if docker_version
  end
end

Facter.add(:docker_version) do
  confine kernel: :linux
  setcode do
    val = nil
    cmd = docker_bin
    if cmd
      value = Facter::Core::Execution.execute(
        cmd + " version --format '{{json .}}'"
      )

      val = JSON.parse(value)
    end
    val
  end
end

Facter.add(:docker) do
  confine kernel: :linux
  setcode do
    val = nil
    cmd = docker_bin
    if cmd
      value = Facter::Core::Execution.execute(
        cmd + " info --format '{{json .}}'"
      )

      val = JSON.parse(value)
    end
    val
  end
end
