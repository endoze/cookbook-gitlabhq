# Handle Git
include_recipe 'gitlabhq::git'

# Handle Ruby
include_recipe 'gitlabhq::ruby'

# Include cookbook dependencies
%w{
  build-essential
  readline
  xml
  zlib
  redisio::install
  redisio::enable
}.each do |recipe|
  include_recipe recipe
end

# Install required packages
node[:gitlab][:packages].each do |pkg|
  package pkg
end

# Install required Ruby Gems
%w{
  bundler
  rake
}.each do |gempkg|
  gem_package gempkg do
    action     :install
  end
end

# Set up redis for Gitlab hooks
link '/usr/bin/redis-cli' do
  to '/usr/local/bin/redis-cli'
end
