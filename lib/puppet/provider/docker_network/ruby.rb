Puppet::Type.type(:docker_network).provide(:ruby) do
  desc "Support for Docker Networking"

  mk_resource_methods
  
  commands :docker_network => "docker"

  def network_conf
     name    = resource[:name]
     create  = resource[:create]
     driver  = resource[:driver]
     subnet  = resource[:subnet]
     gateway = resource[:gateway]
     iprange = resource[:iprange]
     connect = resource[:connect]

     if create.to_s.strip.length == 0
     	conf = ['network', 'connect', "#{name}"]
     else  
         conf = ['network', 'create', '--driver', "#{driver}", "#{name}", '--subnet', "#{subnet}", '--gateway', "#{gateway}" '--iprange', "#{iprange}"]
         if subnet.to_s.strip.length == 0 then conf.delete("--subnet")
         end
         if gateway.to_s.strip.length == 0 then conf.delete("--gateway")
         end	
         if iprange.to_s.strip.length == 0 then conf.delete("--iprange")
         end
         conf.reject { |item| item.nil? || item == '' }  
       end
    end
    
  def exists?
    Puppet.info("checking if docker network exists")
      name = (resource[:name])
      i =  `docker network ls | grep #{name}`
      ! i.length.eql? 0
  end
 
  def create
     Puppet.info("configuring network")
     docker_network *network_conf
  end  
   
  def destroy
    Puppet.info("removing docker network")
    name = (resource[:name])
    `docker network rm #{name}`
   end
 end
