
# GITLAB SHELL
default[:gitlab][:ssh_port]            = 22
default[:gitlab][:gitlab_shell_url]    = 'git://github.com/gitlabhq/gitlab-shell.git'
default[:gitlab][:gitlab_shell_branch] = 'v1.4.0'
default[:gitlab][:gitlab_shell_home]   = "#{node[:gitlab][:home]}/gitlab-shell"
default[:gitlab][:gitlab_shell_user]   = 'git'
default[:gitlab][:repos_path]          = "#{node[:gitlab][:home]}/repositories"
default[:gitlab][:auth_file]           = "#{node[:gitlab][:home]}/.ssh/authorized_keys"
default[:gitlab][:backup_path]         = "#{node[:gitlab][:app_home]}/backups"
default[:gitlab][:redis_binary_path]   = '/usr/bin/redis-cli'
default[:gitlab][:redis_host]          = '127.0.0.1'
default[:gitlab][:redis_port]          = 6379
default[:gitlab][:redis_socket]        = '/tmp/redis.socket'
default[:gitlab][:redis_namespace]     = 'resque:gitlab'
default[:gitlab][:trust_local_sshkeys] = 'yes'
