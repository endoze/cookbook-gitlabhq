#
# Cookbook Name:: gitlabhq
# Recipe:: default
#
# Copyright 2013, Wide Eye Labs
#
# MIT License
#

# Install ruby
include_recipe 'rvm::system_install'
rvm_environment node[:gitlab][:install_ruby]
include_recipe 'backup'

aws_credentials = data_bag_item('credentials', 'aws_credentials')

# Create a Backup gem configuration file
backup_generate_config node.name

# Make Backup gem configuration file owned by backup user
template '/opt/backup/config.rb' do
  cookbook 'backup'
  source   'config.rb.erb'
end

# Install packages that backup gem depends on
[ 'libxml2-dev', 'libxslt1-dev' ].each do |pkg|
  package pkg
end

# Install the Backup gem
gem_package 'backup'

# Install Backup gem dependencies
# Must be done in this order.
%w{
  net-ssh
  net-scp
  excon
  fog
}.each do |gem|
  rvm_gem gem do
    ruby_string node[:gitlab][:install_ruby]
  end
end

# Create a Backup Gem Model for repositories
backup_generate_model 'gitlab_repos' do
  description 'backup of gitlab repositories'
  backup_type 'archive'
  split_into_chunks_of 250
  store_with({
    'engine' => 'S3',
    'settings' => {
      's3.region'            => node[:gitlab][:backup][:s3_region],
      's3.bucket'            => node[:gitlab][:backup][:s3_bucket],
      's3.path'              => "#{node[:gitlab][:backup][:s3_path]}/#{node.name}",
      's3.keep'              => node[:gitlab][:backup][:s3_keep],
      's3.access_key_id'     => aws_credentials['backup']['access_key_id'],
      's3.secret_access_key' => aws_credentials['backup']['secret_access_key']
    }
  })
  options({
    'add' => [node[:gitlab][:repos_path]]
  })
  action :backup
end

gitlab_db_config = gitlab_database_config

gitlab_database_options = {
  "db.name"     => "'#{gitlab_db_config.database}'",
  "db.username" => "'#{gitlab_db_config.username}'",
  "db.password" => "'#{gitlab_db_config.password}'",
  "db.host"     => "'#{gitlab_db_config.host}'",
  "db.port"     => gitlab_db_config.port,
}

#gitlab_database_options = gitlab_database_options.each { |k,v| gitlab_database_options.delete(k) if v.nil? || v.empty? }

# Create a Backup Gem Model for database
backup_generate_model 'gitlab_database' do
  description 'backup of gitlab ci database'
  backup_type 'database'
  database_type gitlab_db_config.database_constant
  split_into_chunks_of 250
  store_with({
    'engine' => 'S3',
    'settings' => {
      's3.region'            => node[:gitlab][:backup][:s3_region],
      's3.bucket'            => node[:gitlab][:backup][:s3_bucket],
      's3.path'              => "#{node[:gitlab][:backup][:s3_path]}/#{node.name}",
      's3.keep'              => node[:gitlab][:backup][:s3_keep],
      's3.access_key_id'     => aws_credentials['backup']['access_key_id'],
      's3.secret_access_key' => aws_credentials['backup']['secret_access_key']
    }
  })
  options gitlab_database_options
  action :backup
end

gitlab_ci_db_config = gitlab_ci_database_config

gitlab_ci_database_options = {
  "db.name"     => "'#{gitlab_ci_db_config.database}'",
  "db.username" => "'#{gitlab_ci_db_config.username}'",
  "db.password" => "'#{gitlab_ci_db_config.password}'",
  "db.host"     => "'#{gitlab_ci_db_config.host}'",
  "db.port"     => gitlab_ci_db_config.port,
}

#gitlab_ci_database_options = gitlab_ci_database_options.each { |k,v| gitlab_ci_database_options.delete(k) if v.nil? || v.empty? }

backup_generate_model 'gitlab_ci_database' do
  description 'backup of gitlab database'
  backup_type 'database'
  database_type gitlab_ci_db_config.database_constant
  split_into_chunks_of 250
  store_with({
    'engine' => 'S3',
    'settings' => {
      's3.region'            => node[:gitlab][:backup][:s3_region],
      's3.bucket'            => node[:gitlab][:backup][:s3_bucket],
      's3.path'              => "#{node[:gitlab][:backup][:s3_path]}/#{node.name}",
      's3.keep'              => node[:gitlab][:backup][:s3_keep],
      's3.access_key_id'     => aws_credentials['backup']['access_key_id'],
      's3.secret_access_key' => aws_credentials['backup']['secret_access_key']}
  })
  options gitlab_ci_database_options
  action :backup
end

%w{
  gitlab_database.rb
  gitlab_ci_database.rb
  gitlab_repos.rb
}.each do | file_path|
  file "/opt/backup/models/#{file_path}" do
    action :touch
    mode 0666
  end
end
