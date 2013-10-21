#
# Cookbook Name:: gitlabhq
# Recipe:: default
#
# Copyright 2013, Wide Eye Labs
#
# MIT License
#

%w{
  gitlabhq::dependencies
  gitlabhq::git
  gitlabhq::ruby
  gitlabhq::database
  gitlabhq::gitlab
  gitlabhq::ci
  gitlabhq::nginx
  gitlabhq::backup
}.each do |recipe|
  include_recipe recipe
end

