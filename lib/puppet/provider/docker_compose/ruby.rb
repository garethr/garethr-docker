Puppet::Type.type(:docker_compose).provide(:ruby) do
  desc "Support for Docker Compose"
  commands :dockercompose => "docker-compose"
    
  mk_resource_methods


  def exists?
    Puppet.info("Checking if docker-compose.yml exists")
    begin
      Dir.chdir(resource[:source])
      File.file?('docker-compose.*')    
    rescue Exception => e
       false 
    end
  end
 
  def create
     Puppet.info("running docker-compose up -d")
     Dir.chdir(resource[:source])
     dockercompose('up', '-d')
  end
   
  def destroy
    Puppet.info("stoping docker-compose containers")
    Dir.chdir(resource[:source])
    dockercompose('stop')
  end
end
