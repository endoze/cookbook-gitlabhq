# Include cookbook dependencies
%w{
  ruby_build
  build-essential
  readline
  sudo
  openssh
  xml
  zlib
  python::package
  python::pip
  redisio::install
  redisio::enable
}.each do |recipe|
  include_recipe recipe
end

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
    action     :install
    gem_binary "#{node[:gitlab][:ruby_dir]}/gem"
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
