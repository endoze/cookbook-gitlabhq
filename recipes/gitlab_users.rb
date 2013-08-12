
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

# Add ruby to ssh env
execute "add-ruby-to-ssh-env" do
  command "echo \"export PATH=#{node[:gitlab][:ruby_dir]}:$PATH\" >> #{node[:gitlab][:home]}/.ssh/environment && touch .markers/.env-set"
  cwd     node[:gitlab][:home]
  user    node[:gitlab][:user]
  group   node[:gitlab][:group]
  creates "#{node[:gitlab][:marker_dir]}/.env-set"
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

execute "add-ruby-to-bash_profile" do
  command "echo \"export PATH=#{node[:gitlab][:ruby_dir]}:$PATH\" >> #{node[:gitlab][:home]}/.bash_profile && touch .markers/.bash_profile-set"
  cwd     node[:gitlab][:home]
  user    node[:gitlab][:user]
  group   node[:gitlab][:group]
  creates "#{node[:gitlab][:marker_dir]}/.bash_profile-set"
end

execute "git-config-username" do
  command "sudo -u git -H bash -l -c \"git config --global user.name Gitlab\""
  creates "#{node[:gitlab][:marker_dir]}/.git_config_username"
end

execute "git-config-email" do
  command "sudo -u git -H bash -l -c \"git config --global user.email gitlab@#{node[:fqdn]}\""
  creates "#{node[:gitlab][:marker_dir]}/.git_config_email"
end
