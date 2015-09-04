require 'shellwords'

module Puppet::Parser::Functions
  # Transforms a hash into a string of docker flags
  newfunction(:docker_run_flags, :type => :rvalue) do |args|
    opts = args[0] || {}
    flags = []

    if opts['username']
      flags << "-u '#{opts['username'].shellescape}'"
    end

    if opts['hostname']
      flags << "-h '#{opts['hostname'].shellescape}'"
    end

    if opts['restart']
      flags << "--restart '#{opts['restart']}'"
    end

    if opts['net']
      flags << "--net #{opts['net']}"
    end

    if opts['memory_limit']
      flags << "-m #{opts['memory_limit']}"
    end

    cpusets = [opts['cpuset']].flatten.compact
    unless cpusets.empty?
      value = cpusets.join(',')
      flags << "--cpuset=#{value}"
    end

    if opts['disable_network']
      flags << '-n false'
    end

    if opts['privileged']
      flags << '--privileged'
    end

    if opts['detach']
      flags << '--detach=true'
    end

    if opts['tty']
      flags << '-t'
    end

    multi_flags = lambda { |values, format|
      filtered = [values].flatten.compact
      filtered.map { |val| sprintf(format, val) }
    }

    [
      ['--dns %s',          'dns'],
      ['--dns-search %s',   'dns_search'],
      ['--expose=%s',       'expose'],
      ['--link %s',         'links'],
      ['--lxc-conf="%s"',   'lxc_conf'],
      ['--volumes-from %s', 'volumes_from'],
      ['-e %s',             'env'],
      ['--env-file %s',     'env_file'],
      ['-p %s',             'ports'],
      ['-l %s',             'labels'],
      ['--add-host %s',     'hostentries'],
      ['-v %s',             'volumes'],
      ['-H %s',             'socket_connect'],
    ].each do |(format, key)|
      values    = opts[key]
      new_flags = multi_flags.call(values, format)
      flags.concat(new_flags)
    end

    opts['extra_params'].each do |param|
      flags << param
    end

    flags.flatten.join(" ")
  end
end
