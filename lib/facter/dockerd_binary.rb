Facter.add(:dockerd_binary) do
  setcode do
    Facter::Core::Execution.which('dockerd')
  end
end
