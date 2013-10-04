#
# Cookbook Name:: gitlabhq
# Recipe:: default
#
# Copyright 2013, Wide Eye Labs
#
# MIT License
#

# Include cookbook dependencies
%w{
  build-essential
  readline
  sudo
  xml
  zlib
  python::package
  python::pip
  redisio::install
  redisio::enable
  hosts_file
}.each do |recipe|
  include_recipe recipe
end

# Install required packages for Gitlab and CI
node[:gitlab][:packages].each do |pkg|
  package pkg
end

# Install ruby
include_recipe 'rvm::system_install'
rvm_environment node[:gitlab][:install_ruby]

# Install required Ruby Gems for Gitlab
node[:gitlab][:gems].each do |gempkg|
  rvm_gem gempkg do
    ruby_string node[:gitlab][:install_ruby]
  end
end
