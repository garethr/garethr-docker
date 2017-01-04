source "https://rubygems.org"

if Gem::Platform.local.os == 'mingw32'

  # pin to known good versions
  gem 'win32-service', '<= 0.8.8',    :require => false
  gem "win32-dir", "<= 0.4.9",        :require => false
  gem "win32-eventlog", "<= 0.6.6",   :require => false
  gem "win32-process", "<= 0.7.5",    :require => false
  gem "win32-security", "<= 0.2.5",   :require => false

  gem 'ruby_dep', '<= 1.3.1'
end  

# https://github.com/puppetlabs/puppet/pull/5152
# Hiera has an unbound dependency on json_pure
# json_pure 2.0.2+ officially requires Ruby >= 2.0, but should have specified that in 2.0
gem 'json_pure', '<= 2.0.1', :require => false

group :test do
  gem "rake", "~> 10.0"
  if puppet_gem_version = ENV['PUPPET_GEM_VERSION']
    gem "puppet", puppet_gem_version
  elsif puppet_git_url = ENV['PUPPET_GIT_URL']
    gem "puppet", :git => puppet_git_url
  else
    gem "puppet"
  end
  
  gem "puppet-lint", '<= 2.0.0'
  gem "puppet-lint-unquoted_string-check"
  gem "rspec-puppet"
  gem "puppet-syntax"
  gem "puppetlabs_spec_helper"
  gem "metadata-json-lint"
  gem "rspec"
  gem "rspec-retry"
  gem "simplecov", ">= 0.11.0"
  gem "simplecov-console"
  gem "json_pure", "<= 2.0.1" # 2.0.2 requires Ruby 2+
end

group :system_tests do
  gem "beaker-puppet_install_helper", :require => false
  gem "beaker-rspec"
  gem "beaker", "~> 2.0"
end

group :development do
  gem "travis"
  gem "travis-lint"
  gem "puppet-blacksmith"
  gem "guard-rake"
  gem "pry"
  gem "yard"
  gem 'parallel_tests' # requires at least Ruby 1.9.3
  gem 'rubocop', :require => false # requires at least Ruby 1.9.2
end
