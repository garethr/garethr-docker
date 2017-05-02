Facter.add(:swarm_extract_tokens, :type => :aggregate) do

  chunk(:token_manager) do
    tokens = {}
    token = Facter::Core::Execution.execute('/usr/bin/docker swarm join-token -q manager 2> /dev/null')
      if token.nil?
        tokens["swarm_tokens"] = {:manager => nil }
      else
        tokens["swarm_tokens"] = {:manager => token}
      end

    tokens
  end

  chunk(:token_worker) do
    tokens = {}
    token = Facter::Core::Execution.execute('/usr/bin/docker swarm join-token -q worker 2> /dev/null')
      if token.nil?
        tokens["swarm_tokens"] = {:worker => nil }
      else
        tokens["swarm_tokens"] = {:worker => token}
      end

    tokens
  end
end
