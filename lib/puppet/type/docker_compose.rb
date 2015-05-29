Puppet::Type.newtype(:docker_compose) do
    @doc = "Runs docker-compose"

    ensurable

    newparam(:name) do
      desc "To add a name to ref whats in the yaml"  
    end
    
    newproperty(:source) do
    desc "location of the docker-compose.yml"
    validate do |value|
           unless value =~ /^\/[a-z0-9]+/
                raise ArgumentError , "%s is not a valid file path" % value 
        end 
     end
   end
end