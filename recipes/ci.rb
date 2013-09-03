
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
    :adapter  => node[:gitlab][:ci][:database][:adapter],
    :encoding => node[:gitlab][:ci][:database][:encoding],
    :host     => node[:gitlab][:ci][:database][:host],
    :database => node[:gitlab][:ci][:database][:database],
    :pool     => node[:gitlab][:ci][:database][:pool],
    :username => node[:gitlab][:ci][:database][:username],
    :password => node[:gitlab][:ci][:database][:password]
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

# Create directory for gitlab ci socket
directory "#{node[:gitlab][:ci][:app_home]}/tmp/pids" do
  user      node[:gitlab][:ci][:user]
  group     node[:gitlab][:ci][:group]
  mode      0755
  action    :create
  recursive true
end

# Install gems with bundle install
without_group = node[:gitlab][:database][:type] == 'mysql' ? 'postgres' : 'mysql'

execute 'gitlab-ci-bundle-install' do
  command "bundle install --without development test #{without_group} --deployment"
  cwd     node[:gitlab][:ci][:app_home]
  user    node[:gitlab][:ci][:user]
  group   node[:gitlab][:ci][:group]
  environment({ 'LANG' => 'en_US.UTF-8', 'LC_ALL' => 'en_US.UTF-8' })
  creates "#{node[:gitlab][:ci][:app_home]}/vendor/bundle"
end

# Setup database for Gitlab Ci
execute 'gitlab-ci-bundle-rake' do
  command "bundle exec rake db:setup RAILS_ENV=production"
  cwd     node[:gitlab][:ci][:app_home]
  user    node[:gitlab][:ci][:user]
  group   node[:gitlab][:ci][:group]
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
