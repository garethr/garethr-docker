Puppet::Type.newtype(:docker_compose) do
    @doc = "Runs docker-compose"

   ensurable 
 
   newparam(:name) do
     desc "Name of the app stack"
   end
    
   newparam(:source) do
     desc "location of the docker-compose.yml"
     validate do |value|
        unless value =~ /^\/[a-z0-9]+/
          raise ArgumentError, "%s is not a valid file path" % value
        end
      end
     defaultto :"/tmp/"
   end

    newparam(:file_name) do
      desc "To change the file name if you are not using the default docker-compose.yml"
      defaultto :"docker-compose.yml"
    end     

    newproperty(:scale, :array_matching => :all) do
      desc "Number of conatiner istances"
      defaultto :"1"
    end   
    
    autorequire(:file) do 
      self[:source] if self[:source] and Pathname.new(self[:source]).absolute? 
    end
end