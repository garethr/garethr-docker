
require 'fileutils'
require 'yaml'


Puppet::Type.type(:docker_compose).provide(:ruby) do
  desc "Support for Docker Compose"
  commands :dockercompose => "docker-compose"
  
  def docker_scale
    app  = YAML.load(File.read("#{resource[:source]}/docker-compose.yml"))
    num  = resource[:scale]
    i = 0
    app.each_key do |key|
      if num[i] == '1' or num[i].nil?
          yield ['up',  '-d', '--no-recreate', "#{key}"]
      else
        yield ['scale', "#{key}=#{num[i]}"]
      end
      i += 1
    end
  end

  def exists?
    Puppet.info("Checking if docker-compose.yml exists")
        Dir.chdir(resource[:source])
        File.file?('docker-compose.*') 
  end
 
  def create
     Puppet.info("bring up containers")
     Dir.chdir(resource[:source])
     docker_scale { |args| dockercompose *args }
  end  
   
  def destroy
    Puppet.info("stoping docker-compose containers")
    Dir.chdir(resource[:source])
    dockercompose('kill')
  end
end
