require 'puppetlabs_spec_helper/module_spec_helper'

if ENV['PARSER'] == 'future'
  RSpec.configure do |c|
    c.parser = 'future'
  end
end
