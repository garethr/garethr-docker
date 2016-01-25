source "https://rubygems.org"

group :test do
  gem "rake"
  gem "puppet", ENV['PUPPET_GEM_VERSION'] || '~> 4.3.0'
  gem "puppet-lint"
  gem "puppet-lint-unquoted_string-check"
  gem "rspec-puppet", "2.2.0"
  gem "puppet-syntax"
  gem "puppetlabs_spec_helper"
  gem "metadata-json-lint"
  gem "rspec", '< 3.2.0' # Support for 1.8.7
  gem "rspec-retry"
  gem 'rubocop', '0.33.0', require: false
  gem 'simplecov', '>= 0.11.0'
  gem 'simplecov-console'
  gem 'parallel_tests'
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
end
