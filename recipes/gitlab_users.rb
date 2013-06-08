
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
execute "add-ruby-to-bashrc" do
  command "echo \"export PATH=#{node[:gitlab][:ruby_dir]}:$PATH\" >> #{node[:gitlab][:home]}/.bashrc && touch .markers/.bashrc-set"
  cwd     node[:gitlab][:home]
  user    node[:gitlab][:user]
  group   node[:gitlab][:group]
  creates "#{node[:gitlab][:marker_dir]}/.bashrc-set"
end

execute "add-ruby-to-bash_profile" do
  command "echo \"export PATH=#{node[:gitlab][:ruby_dir]}:$PATH\" >> #{node[:gitlab][:home]}/.bash_profile && touch .markers/.bash_profile-set"
  cwd     node[:gitlab][:home]
  user    node[:gitlab][:user]
  group   node[:gitlab][:group]
  creates "#{node[:gitlab][:marker_dir]}/.bash_profile-set"
end
