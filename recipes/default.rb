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
  gitlabhq::gitlab_users
  gitlabhq::gitlab_shell
  gitlabhq::database
  gitlabhq::gitlab
  gitlabhq::nginx
}.each do |recipe|
    include_recipe recipe
  end

# Start gitlab and nginx service
%w{ nginx }.each do |svc|
  service svc do
    action [ :enable, :start]
  end
end

execute "sidekiq-start" do
  command "sudo -u git -H bash -l -c \"RAILS_ENV=production bundle exec rake sidekiq:start\""
  cwd     node[:gitlab][:app_home]
  creates "#{node[:gitlab][:app_home]}/tmp/pids/sidekiq.pid"
end

execute "gitlab-start" do
  command "sudo -u git -H bash -l -c \"RAILS_ENV=production bundle exec puma -C #{node[:gitlab][:app_home]}/config/puma.rb\""
  cwd     node[:gitlab][:app_home]
  creates "#{node[:gitlab][:app_home]}/tmp/pids/puma.pid"
end
