require 'pathname'
require Pathname.new(__FILE__).dirname + '../' + 'puppet_x/docker/docker_env'

Facter.add('all_users_profile') do
  confine :osfamily => :windows
  setcode do
    PuppetX::Docker::DockerEnv.all_users_profile || "C:\\ProgramData"
  end
end

Facter.add('docker_binpath') do
  if Puppet::Util::Platform.windows?
    setcode do
      PuppetX::Docker::DockerEnv.bin || "C:\\Program Files\\Docker\\Docker\\resources\\bin"
    end
  else
    setcode do
      PuppetX::Docker::DockerEnv.bin || "/usr/bin"
    end
  end
end
