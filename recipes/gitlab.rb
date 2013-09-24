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
  only_if  { node[:gitlab][:user_create] === true }
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
    :app_home    => node[:gitlab][:app_home],
    :app_user    => node[:gitlab][:user],
    :environment => node[:gitlab][:environment]
  )
end

# Register gitlab service
service 'gitlab' do
  supports :status => true, :restart => true, :reload => true
end

# Start gitlab on boot
execute 'gitlab-on-boot' do
  command "update-rc.d gitlab defaults 21"
end

# Render gitlab config file
template "#{node[:gitlab][:app_home]}/config/gitlab.yml" do
  source "gitlab.yml.erb"
  owner  node[:gitlab][:user]
  group  node[:gitlab][:group]
  mode   0644
  variables(
    :fqdn              => node[:gitlab][:server_name],
    :https_boolean     => node[:gitlab][:https],
    :git_user          => node[:gitlab][:user],
    :git_bin           => "#{node[:git][:prefix]}/bin/git",
    :email_from        => node[:gitlab][:email_from],
    :support_email     => node[:gitlab][:support_email],
    :satellite_path    => node[:gitlab][:satellite_path],
    :shell_repos_path  => node[:gitlab][:shell][:repos_path],
    :shell_hooks_path  => node[:gitlab][:shell][:hooks_path],
    :shell_ssh_port    => node[:gitlab][:shell][:ssh_port],
    :backup_path       => node[:gitlab][:backup_path],
    :backup_keep_time  => node[:gitlab][:backup_keep_time]
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
directory node[:gitlab][:backup_path] do
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
if node[:gitlab][:environment] == 'production'
  without_group << ' development test'
end

execute "gitlab-bundle-install-#{node[:gitlab][:environment]}" do
  command "bundle install --deployment --without #{without_group} && touch #{node[:gitlab][:marker_dir]}/.gitlab-bundle-#{node[:gitlab][:environment]}"
  cwd     node[:gitlab][:app_home]
  user    node[:gitlab][:user]
  group   node[:gitlab][:group]
  environment({ 'LANG' => 'en_US.UTF-8', 'LC_ALL' => 'en_US.UTF-8' })
  creates "#{node[:gitlab][:marker_dir]}/.gitlab-bundle-#{node[:gitlab][:environment]}"
end

# Respect old .gitlab-setup file
file "#{node[:gitlab][:marker_dir]}/.gitlab-setup-production" do
  user    node[:gitlab][:user]
  group   node[:gitlab][:group]
  action  :create_if_missing
  only_if  { File.exist?("#{node[:gitlab][:marker_dir]}/.gitlab-setup") }
end

node[:gitlab][:ci][:envs].each do |env|
  # Setup database for Gitlab
  execute "gitlab-bundle-rake-#{env}" do
    command "bundle exec rake gitlab:setup RAILS_ENV=#{env} force=yes && touch #{node[:gitlab][:marker_dir]}/.gitlab-setup-#{env}"
    cwd     node[:gitlab][:app_home]
    user    node[:gitlab][:user]
    group   node[:gitlab][:group]
    creates "#{node[:gitlab][:marker_dir]}/.gitlab-setup-#{env}"
  end
end

# Render gitconfig into gitlab users home
template File.join(Dir.home(node[:gitlab][:user]), '.gitconfig') do
  source "gitlab.gitconfig.erb"
  owner  node[:gitlab][:user]
  group  node[:gitlab][:group]
  mode   0644
end

# Backup
include_recipe 'gitlabhq::backup'

# Hostsfile
hostsfile_entry '127.0.0.1' do
  hostname  node[:gitlab][:hostsfile_entry]
  action    :append
  not_if    { node[:gitlab][:hostsfile_entry].empty? }
end

# Enable and start gitlab service
service 'gitlab' do
  action [ :enable, :restart ]
end

# Make available through webserver
case node[:gitlab][:webserver][:type]
  when 'nginx'
    include_recipe 'gitlabhq::webserver_nginx_gitlab'
end
