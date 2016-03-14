source "https://rubygems.org"

group :test do
  gem "rake", "~> 10.0"
  if puppet_gem_version = ENV['PUPPET_GEM_VERSION']
    gem "puppet", ENV['PUPPET_GEM_VERSION']
  elsif puppet_git_url = ENV['PUPPET_GIT_URL']
    gem "puppet", :git => "#{puppet_git_url}"
  else
    gem "puppet", ENV['PUPPET_GEM_VERSION']
  end
  gem "puppet-lint"
  gem "puppet-lint-unquoted_string-check"
  gem "rspec-puppet", "2.2.0"
  gem "puppet-syntax"
  gem "puppetlabs_spec_helper"
  gem "metadata-json-lint"
  gem "rspec", '< 3.2.0' # Support for 1.8.7
  gem "rspec-retry"
  gem 'simplecov', '>= 0.11.0'
  gem 'simplecov-console'
end

group :development do
  gem "travis"
  gem "travis-lint"
  gem "beaker", "~> 2.0"
  gem "beaker-puppet_install_helper", :require => false
  gem "beaker-rspec"
  gem "puppet-blacksmith"
  gem "guard-rake"
  gem "pry"
  gem "yard"
  gem 'parallel_tests' # requires at least Ruby 1.9.3
  gem 'rubocop', :require => false # requires at least Ruby 1.9.2
end
