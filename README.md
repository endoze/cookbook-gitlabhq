GitLabHQ Cookbook
=================
This cookbook installs and configures GitLab.

[![Build Status](https://secure.travis-ci.org/WideEyeLabs/cookbook-gitlabhq.png)](http://travis-ci.org/WideEyeLabs/cookbook-gitlabhq?branch=master)

Requirements
------------
- Hard disk space
  - Around 200 mb plus space for your repositories

Attributes
----------
#### gitlabhq::default

```ruby
default[:gitlab][:install_ruby] = '1.9.3-p392'
default[:gitlab][:ruby_dir] = "/usr/local/ruby/#{node[:gitlab][:install_ruby]}/bin"

# GITLAB USER
default[:gitlab][:user] = 'git'
default[:gitlab][:group] = 'git'
default[:gitlab][:home] = '/home/git'
default[:gitlab][:app_home] = "#{node[:gitlab][:home]}/gitlab"
default[:gitlab][:environment] = 'production'
default[:gitlab][:marker_dir] = "#{node[:gitlab][:home]}/.markers"

# GITLAB SHELL
default[:gitlab][:ssh_port] = 22
default[:gitlab][:gitlab_shell_url] = 'git://github.com/gitlabhq/gitlab-shell.git'
default[:gitlab][:gitlab_shell_branch] = 'v1.4.0'
default[:gitlab][:gitlab_shell_home] = "#{node[:gitlab][:home]}/gitlab-shell"
default[:gitlab][:gitlab_shell_user] = 'git'
default[:gitlab][:repos_path] = "#{node[:gitlab][:home]}/repositories"
default[:gitlab][:auth_file] = "#{node[:gitlab][:home]}/.ssh/authorized_keys"
default[:gitlab][:backup_path] = "#{node[:gitlab][:app_home]}/backups"
default[:gitlab][:redis_binary_path] = '/usr/bin/redis-cli'
default[:gitlab][:redis_host] = '127.0.0.1'
default[:gitlab][:redis_port] = 6379
default[:gitlab][:redis_socket] = '/tmp/redis.socket'
default[:gitlab][:redis_namespace] = 'resque:gitlab'
default[:gitlab][:trust_local_sshkeys] = 'yes'

# DATABASE
default[:gitlab][:database][:type] = 'mysql'
default[:gitlab][:database][:adapter] =  default[:gitlab][:database][:type] == 'mysql' ? 'mysql2' : 'postgresql'
default[:gitlab][:database][:encoding] = default[:gitlab][:database][:type] == 'mysql' ? 'utf8' : 'unicode'
default[:gitlab][:database][:host] = 'localhost'
default[:gitlab][:database][:pool] = 5
default[:gitlab][:database][:database] = 'gitlab'
default[:gitlab][:database][:username] = 'gitlab'

# GITLAB
default[:gitlab][:gitlab_url] = 'git://github.com/gitlabhq/gitlabhq.git'
default[:gitlab][:gitlab_branch] = 'v5.2.0'
default[:gitlab][:backup_keep_time] = 604800
default[:gitlab][:https] = false
default[:gitlab][:ssl_certificate] = "/etc/nginx/#{node[:fqdn]}.crt"
default[:gitlab][:ssl_certificate_key] = "/etc/nginx/#{node[:fqdn]}.key"
default[:gitlab][:ssl_req] = "/C=US/ST=Several/L=Locality/O=Example/OU=Operations/CN=#{node[:fqdn]}/emailAddress=root@localhost"
```

Usage
-----
#### gitlabhq::default

Just include `gitlabhq` in your node's `run_list`:

```json
{
  "name":"my_node",
  "run_list": [
    "recipe[gitlabhq]"
  ]
}
```

Contributing
------------
1. Fork the repository on Github
2. Create a named feature branch (like `my_cool_feature`)
3. Write you change
4. Write tests for your change (if applicable)
5. Run the tests, ensuring they all pass
6. Submit a Pull Request using Github

License and Authors
-------------------
Authors: chris@wideeyelabs.com
