require 'pathname'
require Pathname.new(__FILE__).dirname + 'docker_env'

module PuppetX
  module Docker
    module DockerCommon

      def docker_cmd
        docker_binpath = PuppetX::Docker::DockerEnv.bin

        if Puppet::Util::Platform.windows?

          # On Windows, may be nil
          if !docker_binpath
            docker_binpath = "C:\\Program Files\\Docker\\Docker\\resources\\bin"
          end

          cmd = docker_binpath + '\docker.exe'
        else
          cmd = docker_binpath + 'docker'
        end

        cmd
      end
      module_function :docker_cmd

      def docker_compose_cmd
        docker_binpath = PuppetX::Docker::DockerEnv.bin

        if Puppet::Util::Platform.windows?

          # On Windows, may be nil
          if !docker_binpath
            docker_binpath = "C:\\Program Files\\Docker\\Docker\\resources\\bin"
          end

          cmd = docker_binpath + '\docker-compose.exe'
        else
          cmd = docker_binpath + 'docker-compose'
        end

        cmd
      end
      module_function :docker_compose_cmd

    end
  end
end
