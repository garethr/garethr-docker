Puppet::Type.newtype(:docker_network) do
    @doc = "Configuration for Docker network"

   ensurable 
 
   newparam(:name) do
     desc "network name"
   end
   
   newparam(:create) do
     desc "Create a network"
   end

   newparam(:driver) do
     desc "the network driver that you want your network to use"
     defaultto :"overlay"
   end

    newparam(:subnet) do
      desc "subnet in CIDR format that represents a network segment"
    end     

    newproperty(:gateway) do
      desc "ipv4 or ipv6 Gateway for the master subnet"
    end   
     
    newproperty(:iprange) do
      desc "allocate container ip from a sub-range"
    end   

     newproperty(:connect) do
      desc "connect a conatiner to the a docker network"
    end    
end