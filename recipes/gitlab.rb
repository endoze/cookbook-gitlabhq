#
# Cookbook Name:: gitlabhq
# Recipe:: default
#
# Copyright 2013, Wide Eye Labs
#
# MIT License
#

include_recipe 'gitlabhq::dependencies'
include_recipe 'gitlabhq::git'

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

# CREATE GIT USER
user node[:gitlab][:user] do
  comment  'Gitlab User'
  home     node[:gitlab][:home]
  shell    '/bin/bash'
  supports :manage_home => true
end

# Create a $HOME/.ssh folder
directory "#{node[:gitlab][:home]}/.ssh" do
  owner  node[:gitlab][:user]
  group  node[:gitlab][:group]
  mode   0700
end

# Add ruby to path
template   "#{node[:gitlab][:home]}/.bashrc" do
  owner    node[:gitlab][:user]
  group    node[:gitlab][:user]
  mode     0644
  source   'bashrc.erb'
  variables(
      :ruby_dir => "#{node[:rvm][:root_path]}/environments/#{node[:gitlab][:install_ruby]}"
  )
end

template "#{node[:gitlab][:home]}/.gitconfig" do
  owner node[:gitlab][:user]
  group node[:gitlab][:user]
  mode 0644
  source 'gitconfig.erb'
  variables(
    :git_user_name => node[:gitlab][:git_username],
    :git_user_email => node[:gitlab][:git_email]
  )
end
#
# INSTALL GITLAB SHELL
git node[:gitlab][:gitlab_shell_home] do
  repository node[:gitlab][:gitlab_shell_url]
  reference  node[:gitlab][:gitlab_shell_branch]
  action     :sync
  user       node[:gitlab][:user]
  group      node[:gitlab][:group]
end

template "#{node[:gitlab][:gitlab_shell_home]}/config.yml" do
  owner  node[:gitlab][:user]
  group  node[:gitlab][:group]
  mode   0644
  variables(
    :git_user         => node[:gitlab][:gitlab_shell_user],
    :repos_path       => node[:gitlab][:repos_path],
    :auth_file        => node[:gitlab][:auth_file],
    :redis_binary     => node[:gitlab][:redis_binary_path],
    :redis_host       => node[:gitlab][:redis_host],
    :redis_port       => node[:gitlab][:redis_port],
    :redis_socket     => node[:gitlab][:redis_socket],
    :redis_namespace  => node[:gitlab][:redis_namespace]
  )
end

rvm_shell "gitlab-shell-install" do
  ruby_string node[:gitlab][:install_ruby]
  cwd         node[:gitlab][:gitlab_shell_home]
  user        node[:gitlab][:user]
  group       node[:gitlab][:group]
  code        %{./bin/install}
  creates     "#{node[:gitlab][:user]}/.ssh/authorized_keys"
end

::Chef::Recipe.send(:include, Gitlabhq::Helper)

gitlab_db_config = gitlab_database_config

include_recipe "#{gitlab_db_config.database_type}::ruby"

# Clone gitlab
git node[:gitlab][:app_home] do
  repository  node[:gitlab][:gitlab_url]
  reference   node[:gitlab][:gitlab_branch]
  action      :sync
  user        node[:gitlab][:user]
  group       node[:gitlab][:group]
end

# Render gitlab init script
template '/etc/init.d/gitlab' do
  owner  'root'
  group  'root'
  mode   0755
  source 'gitlab.init.erb'
  variables(
    :app_home  => node[:gitlab][:app_home],
    :app_user  => node[:gitlab][:user]
  )
end

service 'gitlab' do
  supports :status => true, :restart => true, :reload => true
  action [ :enable, :start ]
end

# Render gitlab config file
template "#{node[:gitlab][:app_home]}/config/gitlab.yml" do
  owner  node[:gitlab][:user]
  group  node[:gitlab][:group]
  mode   0644
  variables(
    :fqdn             => node[:gitlab][:server_name],
    :https_boolean    => node[:gitlab][:https],
    :git_user         => node[:gitlab][:git_user],
    :git_home         => node[:gitlab][:git_home],
    :satellite_path   => node[:gitlab][:satellite_path],
    :git_path         => "#{node[:git][:prefix]}/bin/git",
    :backup_path      => node[:gitlab][:backup_path],
    :backup_keep_time => node[:gitlab][:backup_keep_time],
    :app_home         => node[:gitlab][:home],
    :ssh_port         => node[:gitlab][:ssh_port]
  )
  notifies :restart, 'service[gitlab]'
end

# Write the database.yml
template "#{node[:gitlab][:app_home]}/config/database.yml" do
  source 'database.yml.erb'
  owner  node[:gitlab][:user]
  group  node[:gitlab][:group]
  mode   0644
  variables(
    :adapter  => gitlab_db_config.adapter,
    :encoding => gitlab_db_config.encoding,
    :host     => gitlab_db_config.host,
    :port     => gitlab_db_config.port,
    :database => gitlab_db_config.database,
    :pool     => gitlab_db_config.pool,
    :username => gitlab_db_config.username,
    :password => gitlab_db_config.password
  )
  notifies :restart, 'service[gitlab]'
end

# Create directory for gitlab socket
directory "#{node[:gitlab][:app_home]}/tmp/sockets" do
  user    node[:gitlab][:user]
  group   node[:gitlab][:group]
  mode    0755
  action  :create
end

# Create directory for satellite repos
directory node[:gitlab][:satellite_path] do
  user   node[:gitlab][:user]
  group  node[:gitlab][:group]
  mode   0755
  action :create
end

# Create the gitlab Backup folder
directory node[:gitlab][:backup_path] do
  owner  node[:gitlab][:user]
  group  node[:gitlab][:group]
  mode   0755
  action :create
end

# Install gems with bundle install
#without_group = node[:gitlab][:database][:type] == 'mysql' ? 'postgres' : 'mysql'

rvm_shell "Gitlab bundle install" do
    ruby_string node[:gitlab][:install_ruby]
    cwd         node[:gitlab][:app_home]
    user        node[:gitlab][:user]
    group       node[:gitlab][:group]
    code        %{bundle install --without development test #{gitlab_db_config.without_group} --deployment}
    creates     "#{node[:gitlab][:app_home]}/vendor/bundle"
end


rvm_shell "Gitlab rake db:migrate" do
    ruby_string node[:gitlab][:install_ruby]
    cwd         node[:gitlab][:app_home]
    user        node[:gitlab][:user]
    group       node[:gitlab][:group]
    code        %{bundle exec rake RAILS_ENV=production db:migrate}
end

# Render puma template
template  "#{node[:gitlab][:app_home]}/config/puma.rb" do
  owner   node[:gitlab][:user]
  group   node[:gitlab][:group]
  mode    0644
  variables(
    :fqdn              => node[:fqdn],
    :app_name          => 'gitlab',
    :app_home          => node[:gitlab][:app_home],
    :environment       => node[:gitlab][:environment],
    :number_of_workers => node[:gitlab][:puma_workers]
  )
  notifies :restart, 'service[gitlab]'
end
