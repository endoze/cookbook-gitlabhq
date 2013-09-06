GitLabHQ Cookbook
=================
This cookbook installs and configures GitLab and GitLab Ci.

[![Build Status](https://secure.travis-ci.org/WideEyeLabs/cookbook-gitlabhq.png?branch=master)](http://travis-ci.org/WideEyeLabs/cookbook-gitlabhq?branch=master)


Installation and Configuration
-----
#### GitLab & GitLab Shell

Add the `gitlab` recipe to your nodes run_list
```ruby
"recipe[gitlab::gitlab]"
```

Available attributes to configure are
```ruby
# GITLAB
default[:gitlab][:server_name]      = 'gitlab.local'
default[:gitlab][:hostsfile_entry]  = node[:gitlab][:server_name]
default[:gitlab][:https]            = true
default[:gitlab][:user]             = 'git'
default[:gitlab][:user_shell]       = '/bin/bash'
default[:gitlab][:user_manage_home] = true
default[:gitlab][:group]            = 'git'
default[:gitlab][:home]             = '/home/git'
default[:gitlab][:email_from]       = "gitlab@#{node[:fqdn]}"
default[:gitlab][:support_email]    = "support@#{node[:fqdn]}"
default[:gitlab][:app_home]         = "#{node[:gitlab][:home]}/gitlab"
default[:gitlab][:marker_dir]       = "#{node[:gitlab][:home]}/.markers"
default[:gitlab][:satellite_path]   = "#{node[:gitlab][:home]}/gitlab-satellites"
default[:gitlab][:url]              = 'https://github.com/gitlabhq/gitlabhq'
default[:gitlab][:gems]             = %w{ charlock_holmes }
default[:gitlab][:python_packages]  = %w{ pygments }

# GITLAB SHELL
default[:gitlab][:shell][:ssh_port]          = 22
default[:gitlab][:shell][:url]               = 'https://github.com/gitlabhq/gitlab-shell'
default[:gitlab][:shell][:app_home]          = "#{node[:gitlab][:home]}/gitlab-shell"
default[:gitlab][:shell][:repos_path]        = "#{node[:gitlab][:home]}/repositories"
default[:gitlab][:shell][:auth_file]         = "#{node[:gitlab][:home]}/.ssh/authorized_keys"
default[:gitlab][:shell][:hooks_path]        = "#{node[:gitlab][:app_home]}/hooks"
default[:gitlab][:shell][:redis_binary_path] = '/usr/bin/redis-cli'
default[:gitlab][:shell][:redis_host]        = '127.0.0.1'
default[:gitlab][:shell][:redis_port]        = 6379
default[:gitlab][:shell][:redis_namespace]   = 'resque:gitlab'

# GITLAB DATABASE
default[:gitlab][:database][:type]     = 'mysql'
default[:gitlab][:database][:adapter]  = default[:gitlab][:database][:type] == 'mysql' ? 'mysql2' : 'postgresql'
default[:gitlab][:database][:encoding] = default[:gitlab][:database][:type] == 'mysql' ? 'utf8' : 'unicode'
default[:gitlab][:database][:host]     = 'localhost'
default[:gitlab][:database][:pool]     = 5
default[:gitlab][:database][:database] = 'gitlab'
default[:gitlab][:database][:username] = 'gitlab'
```

#### GitLab Ci

Add the `gitlab_ci` recipe to your nodes run_list
```ruby
"recipe[gitlab::gitlab_ci]"
```

Available attributes to configure are 
```ruby
# GITLAB CI
default[:gitlab][:ci][:server_name]      = 'gitlab_ci.local'
default[:gitlab][:ci][:hostsfile_entry]  = node[:gitlab][:ci][:server_name]
default[:gitlab][:ci][:user]             = node[:gitlab][:user]
default[:gitlab][:ci][:user_shell]       = node[:gitlab][:user_shell]
default[:gitlab][:ci][:user_manage_home] = node[:gitlab][:user_manage_home]
default[:gitlab][:ci][:group]            = node[:gitlab][:group]
default[:gitlab][:ci][:home]             = node[:gitlab][:home]
default[:gitlab][:ci][:app_home]         = "#{node[:gitlab][:ci][:home]}/gitlab-ci"
default[:gitlab][:ci][:marker_dir]       = "#{node[:gitlab][:ci][:home]}/.markers"
default[:gitlab][:ci][:url]              = 'https://github.com/gitlabhq/gitlab-ci'
default[:gitlab][:ci][:puma_environment] = 'production'
default[:gitlab][:ci][:puma_workers]     = 1

# GITLAB CI DATABASE
default[:gitlab][:ci][:database][:type]     = 'mysql'
default[:gitlab][:ci][:database][:adapter]  = node[:gitlab][:ci][:database][:type] == 'mysql' ? 'mysql2' : 'postgresql'
default[:gitlab][:ci][:database][:encoding] = node[:gitlab][:ci][:database][:type] == 'mysql' ? 'utf8' : 'unicode'
default[:gitlab][:ci][:database][:host]     = 'localhost'
default[:gitlab][:ci][:database][:pool]     = 5
default[:gitlab][:ci][:database][:database] = 'gitlab_ci'
default[:gitlab][:ci][:database][:username] = 'gitlab_ci'
```

#### Both

If you want to install both you can just add the default recipe, which includes `gitlab` and `gitlab_ci`
```ruby
"recipe[gitlab]"
```

#### Configure Webserver

```ruby
# WEBSERVER
default[:gitlab][:webserver][:type]                = 'nginx'
default[:gitlab][:webserver][:ssl_certificate]     = "/etc/#{node[:gitlab][:webserver][:type]}/#{node[:fqdn]}.crt"
default[:gitlab][:webserver][:ssl_certificate_key] = "/etc/#{node[:gitlab][:webserver][:type]}/#{node[:fqdn]}.key"
default[:gitlab][:webserver][:ssl_req]             = "/C=US/ST=Several/L=Locality/O=Example/OU=Operations/CN=#{node[:fqdn]}/emailAddress=root@localhost"
```

If you want to deactivate the installation and configuration of a webserver just set the type to `false`
```ruby
default[:gitlab][:webserver][:type] = false
```

#### Configure Backup

Available attributes to configure are 

```ruby
default[:gitlab][:backup][:path]             = "#{node[:gitlab][:app_home]}/backups"
default[:gitlab][:backup][:keep_time]        = 604800
default[:gitlab][:backup][:remote][:handler] = []
```

#### Configure Remote Backup to AWS S3

Add `aws` to the backup remote handler attribute

```ruby
default[:gitlab][:backup][:remote][:handler] = ['aws']
```

Available attributes to configure are 
```ruby
default[:gitlab][:backup][:remote][:aws][:s3_region] = 'us-east-1'
default[:gitlab][:backup][:remote][:aws][:s3_bucket] = 'gitlab-repo-backups'
default[:gitlab][:backup][:remote][:aws][:s3_path]   = '/backups'
default[:gitlab][:backup][:remote][:aws][:s3_keep]   = 10
```

#### Configure Hosts File Handling

Using the `hostsfile` cookbook we automatically add aliases for `127.0.0.1` to your nodes hosts file. You can configure the entry with the attributes
```rub
# GITLAB
default[:gitlab][:hostsfile_entry] = node[:gitlab][:server_name]

# GITLAB CI
default[:gitlab][:ci][:hostsfile_entry] = node[:gitlab][:ci][:server_name]
```

If you want to deactivate this behaviour just set the attribute to `false`
```ruby
# GITLAB
default[:gitlab][:hostsfile_entry] = false 

# GITLAB CI
default[:gitlab][:ci][:hostsfile_entry] = false 
```

#### Configure Git

We use the `git::default` recipe to handle git installation per default. You can change this to `git::source` by setting the attribute
```ruby
# GIT
default[:gitlab][:git][:include_recipe] = "source"
```

If you use the source recipe the following attributes are set from us
```ruby
# GIT::SOURCE
default[:git][:prefix] = "/usr/local"
default[:git][:version] = "1.8.4"
default[:git][:url] = "https://git-core.googlecode.com/files/git-#{node[:git][:version]}.tar.gz"
default[:git][:checksum] = "ed6dbf91b56c1540627563b5e8683fe726dac881ae028f3f17650b88fcb641d7"
```

#### Configure Ruby

Based on the platform of your node we install ruby through package or with the `ruby_build` cookbook

You can force to install ruby with `ruby_build` by overwriting the attribute
```ruby
default[:gitlab][:install_ruby] = '1.9.3-p392'
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
Authors:
- chris@wideeyelabs.com
- Gerald L. Hevener Jr. (2012)
- Eric G. Wolfe (2012)
  
License: MIT
