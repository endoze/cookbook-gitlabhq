#
# Cookbook Name:: gitlabhq
# Recipe:: default
#
# Copyright 2013, Wide Eye Labs
#
# MIT License
#

# home_dir = node[:gitlab][:home]
# git_user = node[:gitlab][:user]
# git_group = node[:gitlab][:group]
# marker_dir = "#{home_dir}/.markers"
# ruby_dir = "/usr/local/ruby/#{node[:gitlab][:install_ruby]}/bin"
# gitlab_home = node[:gitlab][:app_home]
# backup_path = node[:gitlab][:backup_path]

include_recipe "gitlabhq::dependencies"

include_recipe "gitlabhq::gitlab_users"

include_recipe "gitlabhq::gitlab_shell"

include_recipe "gitlabhq::database"

include_recipe "gitlabhq::gitlab"

include_recipe "gitlabhq::nginx"

# Start gitlab and nginx service
%w{ nginx }.each do |svc|
  service svc do
    action [ :enable, :start]
  end
end

