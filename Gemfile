source "https://rubygems.org"

group :test do
  gem "rake"
  gem "puppet", ENV['PUPPET_GEM_VERSION'] || '~> 3.8.0'
  gem "puppet-lint"
  gem "puppet-lint-unquoted_string-check"
  gem "rspec-puppet", :git => 'https://github.com/rodjek/rspec-puppet.git'
  gem "puppet-syntax"
  gem "puppetlabs_spec_helper"
  gem "metadata-json-lint"
  gem "rspec", '< 3.2.0'
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
