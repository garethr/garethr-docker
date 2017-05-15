require 'json'

Facter.add(:docker_info) do
  setcode do
    if Facter::Util::Resolution.which('docker')
      output = Facter::Util::Resolution.exec('docker info --format "{{json .}}" 2>&1')
      JSON.parse(output)
    end
  end
end

