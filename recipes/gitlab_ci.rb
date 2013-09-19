include_recipe 'gitlabhq::dependencies'

# Setup database
case node[:gitlab][:database][:type]
when 'mysql'
  include_recipe 'gitlabhq::database_mysql_gitlab_ci'
when 'postgres'
  include_recipe 'gitlabhq::database_postgres_gitlab_ci'
end

# Create Gitlab CI user
user node[:gitlab][:ci][:user] do
  home     node[:gitlab][:ci][:home]
  shell    node[:gitlab][:ci][:user_shell]
  supports :manage_home => node[:gitlab][:ci][:user_manage_home]
  only_if  { node[:gitlab][:ci][:user_create] === true }
end

# Create directory to store markers in
directory node[:gitlab][:ci][:marker_dir] do
  owner   node[:gitlab][:ci][:user]
  group   node[:gitlab][:ci][:group]
  mode    0700
end

# Clone gitlab-ci
git node[:gitlab][:ci][:app_home] do
  repository  node[:gitlab][:ci][:url]
  reference   node[:gitlab][:ci][:branch]
  action      :checkout
  user        node[:gitlab][:ci][:user]
  group       node[:gitlab][:ci][:group]
end

# Render gitlab init script
template '/etc/init.d/gitlab_ci' do
  owner  'root'
  group  'root'
  mode   0755
  source 'gitlab_ci.init.erb'
  variables(
    :app_home         => node[:gitlab][:ci][:app_home],
    :app_user         => node[:gitlab][:ci][:user],
    :environment      => node[:gitlab][:ci][:environment],
    :puma_environment => node[:gitlab][:ci][:puma_environment]
  )
end

# Register and start service
service 'gitlab_ci' do
  supports :status => true, :restart => true, :reload => true
  action [ :enable, :start ]
  retries 2
  ignore_failure true
end

# Start ci on boot
execute 'gitlab-ci-on-boot' do
  command "update-rc.d gitlab_ci defaults 21"
end

# Render gitlab ci config file
template "#{node[:gitlab][:ci][:app_home]}/config/application.yml" do
  owner    node[:gitlab][:ci][:user]
  group    node[:gitlab][:ci][:group]
  mode     0644
  source   'gitlab_ci.application.yml.erb'
  variables(
    :allowed_urls => [node[:gitlab][:ci][:allowed_urls]]
  )
  notifies :restart, 'service[gitlab_ci]', :delayed
end

# Write the database.yml
template "#{node[:gitlab][:ci][:app_home]}/config/database.yml" do
  source 'gitlab_ci.database.yml.erb'
  owner  node[:gitlab][:ci][:user]
  group  node[:gitlab][:ci][:group]
  mode   0644
  variables(
    :adapter  => node[:gitlab][:ci][:database][:adapter],
    :encoding => node[:gitlab][:ci][:database][:encoding],
    :host     => node[:gitlab][:ci][:database][:host],
    :database => node[:gitlab][:ci][:database][:database],
    :pool     => node[:gitlab][:ci][:database][:pool],
    :username => node[:gitlab][:ci][:database][:username],
    :password => node[:gitlab][:ci][:database][:password]
  )
  notifies :restart, 'service[gitlab_ci]', :delayed
end

# Create directory for gitlab ci socket
directory "#{node[:gitlab][:ci][:app_home]}/tmp/sockets" do
  user      node[:gitlab][:ci][:user]
  group     node[:gitlab][:ci][:group]
  mode      0755
  action    :create
  recursive true
end

# Create directory for gitlab ci socket
directory "#{node[:gitlab][:ci][:app_home]}/tmp/pids" do
  user      node[:gitlab][:ci][:user]
  group     node[:gitlab][:ci][:group]
  mode      0755
  action    :create
  recursive true
end

# Install gems with bundle install
without_group = node[:gitlab][:database][:type]   == 'mysql' ? 'postgres' : 'mysql'
if node[:gitlab][:ci][:environment] == 'production'
  without_group << ' development test'
end

execute 'gitlab-ci-bundle-install' do
  command "bundle install --deployment --without #{without_group} && touch #{node[:gitlab][:ci][:marker_dir]}/.gitlab-ci-bundle-#{node[:gitlab][:ci][:environment]}"
  cwd     node[:gitlab][:ci][:app_home]
  user    node[:gitlab][:ci][:user]
  group   node[:gitlab][:ci][:group]
  environment({ 'LANG' => 'en_US.UTF-8', 'LC_ALL' => 'en_US.UTF-8' })
  creates "#{node[:gitlab][:ci][:marker_dir]}/.gitlab-ci-setup-#{node[:gitlab][:ci][:environment]}"
end

# Respect old .gitlab-ci-setup file
file "#{node[:gitlab][:ci][:marker_dir]}/.gitlab-ci-setup-production" do
  user    node[:gitlab][:ci][:user]
  group   node[:gitlab][:ci][:group]
  action  :create_if_missing
  only_if  { File.exist?("#{node[:gitlab][:ci][:marker_dir]}/.gitlab-ci-setup") }
end

node[:gitlab][:ci][:envs].each do |env|
  # Setup database for Gitlab Ci
  execute 'gitlab-ci-bundle-rake' do
    command "bundle exec rake db:setup RAILS_ENV=#{env} && touch #{node[:gitlab][:ci][:marker_dir]}/.gitlab-ci-setup-#{env}"
    cwd     node[:gitlab][:ci][:app_home]
    user    node[:gitlab][:ci][:user]
    group   node[:gitlab][:ci][:group]
    creates "#{node[:gitlab][:ci][:marker_dir]}/.gitlab-ci-setup-#{env}"
  end
end

# Render puma template
template  "#{node[:gitlab][:ci][:app_home]}/config/puma.rb" do
  source "gitlab_ci.puma.rb.erb"
  owner   node[:gitlab][:ci][:user]
  group   node[:gitlab][:ci][:group]
  mode    0644
  variables(
    :fqdn        => node[:gitlab][:ci][:server_name],
    :app_name    => 'gitlab-ci',
    :app_home    => node[:gitlab][:ci][:app_home],
    :environment => node[:gitlab][:ci][:puma_environment]
  )
  notifies :restart, 'service[gitlab_ci]', :delayed
end

# Hostsfile
hostsfile_entry '127.0.0.1' do
  hostname  node[:gitlab][:ci][:hostsfile_entry]
  action    :append
  not_if    { node[:gitlab][:ci][:hostsfile_entry].empty? }
end

# Make available through webserver
case node[:gitlab][:webserver][:type]
  when 'nginx'
    include_recipe 'gitlabhq::webserver_nginx_gitlab_ci'
end
