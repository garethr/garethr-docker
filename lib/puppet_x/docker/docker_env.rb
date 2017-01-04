module PuppetX
  module Docker
    class DockerEnv

      if Puppet::Util::Platform.windows?
        require 'win32/registry'
      end

      def self.bin
        value = nil

        if Puppet::Util::Platform.windows?
          begin
            hive = Win32::Registry::HKEY_LOCAL_MACHINE
            hive.open('SOFTWARE\Docker Inc.\Docker\1.0', Win32::Registry::KEY_READ | 0x100) do |reg|
              value = reg['BinPath']
            end
          rescue Win32::Registry::Error => e
            puts(e)
            value = nil
          end
        else
          # TODO: non-Windows path? Should check if binary is actually there.
          # Currently used only in docker_common.rb, docker_env.rb<facter>, network / compose providers
          # Fact is not used on non-Windows plats, as paths hard coded on those.
          value = ''
        end

        if value
          value = value.gsub('"','')
        end

        value
      end
      
      # TODO: find ALLUSERSPROFILE reg?
      def self.all_users_profile
        value = nil
        
        if Puppet::Util::Platform.windows?
          begin
            hive = Win32::Registry::HKEY_LOCAL_MACHINE
            hive.open('SOFTWARE\Microsoft\Windows NT\CurrentVersion\ProfileList', Win32::Registry::KEY_READ | 0x100) do |reg|
              value = reg['ProgramData']
            end
          rescue Win32::Registry::Error => e
            value = nil
          end
        end

        if value
          value = value.gsub('"','')
        end

        value
      end

    end
  end
end

