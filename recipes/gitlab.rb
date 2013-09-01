
# Clone gitlab
git node[:gitlab][:app_home] do
  repository  node[:gitlab][:gitlab_url]
  reference   node[:gitlab][:gitlab_branch]
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
    :git_user  => node[:gitlab][:user]
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
    :fqdn             => node[:fqdn],
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
    :adapter  => node[:gitlab][:database][:adapter],
    :encoding => node[:gitlab][:database][:encoding],
    :host     => node[:gitlab][:database][:host],
    :database => node[:gitlab][:database][:database],
    :pool     => node[:gitlab][:database][:pool],
    :username => node[:gitlab][:database][:username],
    :password => node[:gitlab][:database][:password]
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
  command "echo 'yes' | bundle exec rake gitlab:setup RAILS_ENV=production && touch #{node[:gitlab][:marker_dir]}/.gitlab-setup"
  cwd     node[:gitlab][:app_home]
  user    node[:gitlab][:user]
  group   node[:gitlab][:group]
  creates "#{node[:gitlab][:marker_dir]}/.gitlab-setup"
end

# Render puma template
template  "#{node[:gitlab][:app_home]}/config/puma.rb" do
  owner   node[:gitlab][:user]
  group   node[:gitlab][:group]
  mode    0644
  variables(
    :fqdn               => node[:fqdn],
    :gitlab_app_home    => node[:gitlab][:app_home],
    :gitlab_environment => node[:gitlab][:environment]
  )
  notifies :restart, 'service[gitlab]'
end
