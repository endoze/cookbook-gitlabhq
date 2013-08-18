
# GITLAB USER
default[:gitlab][:user]        = 'git'
default[:gitlab][:group]       = 'git'
default[:gitlab][:home]        = '/home/git'
default[:gitlab][:app_home]    = "#{node[:gitlab][:home]}/gitlab"
default[:gitlab][:environment] = 'production'
default[:gitlab][:marker_dir]  = "#{node[:gitlab][:home]}/.markers"
