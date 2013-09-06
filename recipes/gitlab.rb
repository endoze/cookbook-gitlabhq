include_recipe 'gitlabhq::dependencies'

# Setup database
case node[:gitlab][:database][:type]
when 'mysql'
  include_recipe 'gitlabhq::database_mysql_gitlab'
when 'postgres'
  include_recipe 'gitlabhq::database_postgres_gitlab'
end

# Create Gitlab user
user node[:gitlab][:user] do
  home     node[:gitlab][:home]
  shell    node[:gitlab][:user_shell]
  supports :manage_home => node[:gitlab][:user_manage_home]
end

# Create directory to store markers in
directory node[:gitlab][:marker_dir] do
  owner   node[:gitlab][:user]
  group   node[:gitlab][:group]
  mode    0700
end

# Include cookbook dependencies
%w{
  python::package
  python::pip
}.each do |recipe|
  include_recipe recipe
end

# Required Ruby Gems
node[:gitlab][:gems].each do |gempkg|
  gem_package gempkg do
    action     :install
  end
end

# Install pygments from pip
node[:gitlab][:python_packages].each do |pypkg|
  python_pip pypkg do
    action :install
  end
end

# Install gitlab shell
include_recipe 'gitlabhq::gitlab_shell'

# Clone gitlab
git node[:gitlab][:app_home] do
  repository  node[:gitlab][:url]
  reference   node[:gitlab][:branch]
  action      :checkout
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

# Define gitlab service
service 'gitlab' do
  supports :status => true, :restart => true, :reload => true
end

# Render gitlab config file
template "#{node[:gitlab][:app_home]}/config/gitlab.yml" do
  source "gitlab.yml.erb"
  owner  node[:gitlab][:user]
  group  node[:gitlab][:group]
  mode   0644
  variables(
    :fqdn              => node[:fqdn],
    :https_boolean     => node[:gitlab][:https],
    :git_user          => node[:gitlab][:user],
    :git_bin           => "#{node[:git][:prefix]}/bin/git",
    :email_from        => node[:gitlab][:email_from],
    :support_email     => node[:gitlab][:support_email],
    :satellite_path    => node[:gitlab][:satellite_path],
    :shell_repos_path  => node[:gitlab][:shell][:repos_path],
    :shell_hooks_path  => node[:gitlab][:shell][:hooks_path],
    :shell_ssh_port    => node[:gitlab][:shell][:ssh_port],
    :backup_path       => node[:gitlab][:backup][:path],
    :backup_keep_time  => node[:gitlab][:backup][:keep_time]
  )
  notifies :restart, 'service[gitlab]', :delayed
end

# Write the database.yml
template "#{node[:gitlab][:app_home]}/config/database.yml" do
  source 'gitlab.database.yml.erb'
  owner  node[:gitlab][:user]
  group  node[:gitlab][:group]
  mode   0644
  variables(
    :adapter  => node[:gitlab][:database][:adapter],
    :encoding => node[:gitlab][:database][:encoding],
    :host     => node[:gitlab][:database][:host],
    :database => node[:gitlab][:database][:database],
    :pool     => node[:gitlab][:database][:pool],
    :username => node[:gitlab][:database][:username],
    :password => node[:gitlab][:database][:password]
  )
  notifies :restart, 'service[gitlab]', :delayed
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
directory node[:gitlab][:backup][:path] do
  owner  node[:gitlab][:user]
  group  node[:gitlab][:group]
  mode   0755
  action :create
end

# Render gitlab unicorn config file
template "#{node[:gitlab][:app_home]}/config/unicorn.rb" do
  source "gitlab.unicorn.rb.erb"
  owner  node[:gitlab][:user]
  group  node[:gitlab][:group]
  mode   0644
  variables(
    :app_home => node[:gitlab][:app_home]
  )
  notifies :restart, 'service[gitlab]', :delayed
end

# Install gems with bundle install
without_group = node[:gitlab][:database][:type] == 'mysql' ? 'postgres' : 'mysql'

execute 'gitlab-bundle-install' do
  command "bundle install --without development test #{without_group} --deployment"
  cwd     node[:gitlab][:app_home]
  user    node[:gitlab][:user]
  group   node[:gitlab][:group]
  environment({ 'LANG' => 'en_US.UTF-8', 'LC_ALL' => 'en_US.UTF-8' })
  creates "#{node[:gitlab][:app_home]}/vendor/bundle"
end

# Setup database for Gitlab
execute 'gitlab-bundle-rake' do
  command "bundle exec rake gitlab:setup RAILS_ENV=production force=yes && touch #{node[:gitlab][:marker_dir]}/.gitlab-setup"
  cwd     node[:gitlab][:app_home]
  user    node[:gitlab][:user]
  group   node[:gitlab][:group]
  creates "#{node[:gitlab][:marker_dir]}/.gitlab-setup"
end

# Configure git
execute "git-config-username" do
  command "git config --global user.name Gitlab && touch #{node[:gitlab][:marker_dir]}/.git-config-username"
  creates "#{node[:gitlab][:marker_dir]}/.git-config-username"
end
execute "git-config-email" do
  command "git config --global user.email #{node[:gitlab][:email_from]} && touch #{node[:gitlab][:marker_dir]}/.git-config-email"
  creates "#{node[:gitlab][:marker_dir]}/.git-config-email"
end

# Enable and start gitlab service
service 'gitlab' do
  action [ :enable, :start ]
end

# Make available through webserver
case node[:gitlab][:webserver][:type]
  when 'nginx'
    include_recipe 'gitlabhq::webserver_nginx_gitlab'
end
