#
# Cookbook Name:: gitlabhq
# Recipe:: default
#
# Copyright 2013, Wide Eye Labs
#
# MIT License
#

include_recipe 'gitlabhq::dependencies'

# Create gitlab ci user
user node[:gitlab][:ci][:user] do
  comment  'Gitlab CI User'
  home     node[:gitlab][:ci][:home]
  shell    '/bin/bash'
  supports :manage_home => true
end

# Add ruby t path for gitlab ci user
template   "#{node[:gitlab][:ci][:home]}/.bashrc" do
  owner    node[:gitlab][:ci][:user]
  group    node[:gitlab][:ci][:user]
  mode     0644
  source   'bashrc.erb'
  variables(
    :ruby_dir => "#{node[:rvm][:root_path]}/environments/#{node[:gitlab][:install_ruby]}"
  )
end

::Chef::Recipe.send(:include, Gitlabhq::Helper)

gitlab_ci_db_config = gitlab_ci_database_config

include_recipe "#{gitlab_ci_db_config.database_type}::ruby"

# Clone gitlab-ci
git node[:gitlab][:ci][:app_home] do
  repository  node[:gitlab][:ci][:url]
  reference   node[:gitlab][:ci][:branch]
  action      :sync
  user        node[:gitlab][:ci][:user]
  group       node[:gitlab][:ci][:group]
end

# Render gitlab ci init script
template '/etc/init.d/gitlab_ci' do
  owner  'root'
  group  'root'
  mode   0755
  source 'ci.init.erb'
  variables(
    :app_name    => 'gitlab-ci',
    :app_home    => node[:gitlab][:ci][:app_home],
    :app_user    => node[:gitlab][:ci][:user]
  )
end

service 'gitlab_ci' do
  supports :status => true, :restart => true, :reload => true
  action [ :enable, :start ]
end

# Render gitlab ci config file
template "#{node[:gitlab][:ci][:app_home]}/config/application.yml" do
  owner    node[:gitlab][:ci][:user]
  group    node[:gitlab][:ci][:group]
  mode     0644
  source   'ci.application.yml'
  variables(
    :allowed_urls => [node[:gitlab][:ci][:allowed_urls]]
  )
  notifies :restart, 'service[gitlab_ci]'
end

# Write the database.yml
template "#{node[:gitlab][:ci][:app_home]}/config/database.yml" do
  source 'database.yml.erb'
  owner  node[:gitlab][:ci][:user]
  group  node[:gitlab][:ci][:group]
  mode   0644
  variables(
    :adapter  => gitlab_ci_db_config.adapter,
    :encoding => gitlab_ci_db_config.encoding,
    :host     => gitlab_ci_db_config.host,
    :database => gitlab_ci_db_config.database,
    :pool     => gitlab_ci_db_config.pool,
    :port     => gitlab_ci_db_config.port,
    :username => gitlab_ci_db_config.username,
    :password => gitlab_ci_db_config.password
  )
  notifies :restart, 'service[gitlab_ci]'
end

# Create directory for gitlab ci socket
directory "#{node[:gitlab][:ci][:app_home]}/tmp/sockets" do
  user      node[:gitlab][:ci][:user]
  group     node[:gitlab][:ci][:group]
  mode      0755
  action    :create
  recursive true
end

# Create directory for gitlab ci pids
directory "#{node[:gitlab][:ci][:app_home]}/tmp/pids" do
  user      node[:gitlab][:ci][:user]
  group     node[:gitlab][:ci][:group]
  mode      0755
  action    :create
  recursive true
end

# Install gems with bundle install
rvm_shell "Gitlab-CI bundle install" do
    ruby_string node[:gitlab][:install_ruby]
    cwd         node[:gitlab][:ci][:app_home]
    user        node[:gitlab][:ci][:user]
    group       node[:gitlab][:ci][:group]
    code        %{bundle install --without development test #{gitlab_ci_db_config.without_group} --deployment}
    creates     "#{node[:gitlab][:ci][:app_home]}/vendor/bundle"
end

# Migrate database
rvm_shell "Gitlab-CI rake db:migrate" do
    ruby_string node[:gitlab][:install_ruby]
    cwd         node[:gitlab][:ci][:app_home]
    user        node[:gitlab][:ci][:user]
    group       node[:gitlab][:ci][:group]
    code        %{bundle exec rake db:migrate RAILS_ENV=production}
end

# Render puma template
template  "#{node[:gitlab][:ci][:app_home]}/config/puma.rb" do
  owner   node[:gitlab][:ci][:user]
  group   node[:gitlab][:ci][:group]
  mode    0644
  variables(
    :fqdn        => node[:fqdn],
    :app_name    => 'gitlab-ci',
    :app_home    => node[:gitlab][:ci][:app_home],
    :environment => node[:gitlab][:ci][:environment]
  )
  notifies :restart, 'service[gitlab_ci]'
end
