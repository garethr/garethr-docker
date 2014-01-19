source "http://rubygems.org"

group :test do
  gem "rake"
  gem "puppet", ENV['PUPPET_VERSION'] || '~> 2.7.0'
  gem "puppet-lint"
  gem "rspec-puppet", '~> 1.0.0'
  gem "puppet-syntax"
  gem "puppetlabs_spec_helper"
end

group :development do
  gem "travis"
  gem "travis-lint"
  gem "rspec-system-puppet"
  gem "rspec-system-serverspec"
  gem "vagrant-wrapper"
  gem "puppet-blacksmith"
end
