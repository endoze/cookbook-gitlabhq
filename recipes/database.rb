#
# Cookbook Name:: gitlabhq
# Recipe:: default
#
# Copyright 2013, Wide Eye Labs
#
# MIT License
#

# Include Gitlabhq::Helper for helper methods
::Chef::Recipe.send(:include, Gitlabhq::Helper)

# Install ruby
include_recipe 'rvm::system_install'
rvm_environment node[:gitlab][:install_ruby]

%w{ gitlab gitlab_ci }.each do |app|
  app_db_config = send("#{app}_database_config")

  %W{
    #{app_db_config.database_type}::server
    database::#{app_db_config.database_type}
    }.each do |recipe|
      include_recipe recipe
    end

  database_connection = {
    :host => 'localhost',
    :username => 'root',
    :password => app_db_config.node_root_password,
    :port => app_db_config.port.to_i
  }

  # Create the database
  database app_db_config.database do
    connection database_connection
    action :create
    provider app_db_config.database_provider
  end

  # Create the database user
  database_user app_db_config.username do
    connection database_connection
    password app_db_config.password
    database_name app_db_config.database
    action :create
    provider app_db_config.database_user_provider
  end

  # Grant all privileges to user on database
  database_user app_db_config.username do
    connection database_connection
    database_name app_db_config.database
    host '%'
    action :grant
    provider app_db_config.database_user_provider
  end
end
