
# CREATE GIT USER
user node[:gitlab][:user] do
  comment  'Gitlab User'
  home     node[:gitlab][:home]
  shell    '/bin/bash'
  supports :manage_home => true
end

# Create directory to store markers in
directory node[:gitlab][:marker_dir] do
  owner   node[:gitlab][:user]
  group   node[:gitlab][:group]
  mode    0700
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
    :ruby_dir => node[:gitlab][:ruby_dir]
  )
end

execute "git-config-username" do
  command "sudo -u git -H bash -l -c \"git config --global user.name Gitlab\""
  creates "#{node[:gitlab][:marker_dir]}/.git_config_username"
end

execute "git-config-email" do
  command "sudo -u git -H bash -l -c \"git config --global user.email gitlab@#{node[:fqdn]}\""
  creates "#{node[:gitlab][:marker_dir]}/.git_config_email"
end
