source "http://rubygems.org"

group :test do
  gem "rake"
  gem "puppet", ENV['PUPPET_VERSION'] || '~> 3.7.0'
  gem "puppet-lint"
  gem "puppet-lint-unquoted_string-check"
  gem "rspec-puppet", :git => 'https://github.com/rodjek/rspec-puppet.git'
  gem "puppet-syntax"
  gem "puppetlabs_spec_helper"
  gem "metadata-json-lint"
end

group :development do
  gem "travis"
  gem "travis-lint"
  gem "beaker", :git => 'https://github.com/puppetlabs/beaker.git'
  gem "beaker-rspec"
  gem "puppet-blacksmith"
  gem "guard-rake"
  gem "pry"
  gem "yard"
end
