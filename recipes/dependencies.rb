# Include cookbook dependencies
include_recipe 'ruby_build'
include_recipe 'build-essential'
include_recipe 'readline'
include_recipe 'sudo'
include_recipe 'openssh'
include_recipe 'xml'
include_recipe 'zlib'
include_recipe 'python::package'
include_recipe 'python::pip'
include_recipe 'redisio::install'
include_recipe 'redisio::enable'

# Install ruby
ruby_build_ruby node[:gitlab][:install_ruby]

# Set PATH for remainder of recipe.
ENV['PATH'] = "#{node[:gitlab][:ruby_dir]}:/usr/local/sbin:/usr/local/bin:/sbin:/bin:/usr/sbin:/usr/bin:/root/bin:"

# Install required packages for Gitlab
node[:gitlab][:packages].each do |pkg|
  package pkg
end

# Install required Ruby Gems for Gitlab
node[:gitlab][:gems].each do |gempkg|
  gem_package gempkg do
    action :install
  end
end

# Install pygments from pip
node[:gitlab][:python_packages].each do |pypkg|
  python_pip pypkg do
    action :install
  end
end

# Set up redis for Gitlab hooks
link '/usr/bin/redis-cli' do
  to '/usr/local/bin/redis-cli'
end
