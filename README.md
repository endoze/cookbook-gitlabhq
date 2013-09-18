GitLabHQ Cookbook
=================
This cookbook installs and configures GitLab and GitLab Ci.

[![Build Status](https://secure.travis-ci.org/WideEyeLabs/cookbook-gitlabhq.png?branch=master)](http://travis-ci.org/WideEyeLabs/cookbook-gitlabhq?branch=master)


Configuration
-----
#### GitLab & GitLab Shell

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
default[:gitlab][:backup_path]      = "#{node[:gitlab][:app_home]}/backups"
default[:gitlab][:backup_keep_time] = 604800

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


#### Webserver

Available attributes to configure are 
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

#### Backup

Available attributes to configure are 

```ruby
default[:gitlab][:backup][:remote][:handler] = []
```

#### Remote Backup to AWS S3

Add `aws_s3` to the backup remote handler attribute

```ruby
default[:gitlab][:backup][:remote][:handler] = [:aws_s3]
```

Available attributes to configure are 
```ruby
default[:gitlab][:backup][:remote][:aws_s3][:region] = 'us-east-1'
default[:gitlab][:backup][:remote][:aws_s3][:bucket] = 'gitlab-repo-backups'
default[:gitlab][:backup][:remote][:aws_s3][:path]   = '/backups'
default[:gitlab][:backup][:remote][:aws_s3][:keep]   = 10
```

#### Hosts File Handling

Using the `hostsfile` cookbook we automatically add aliases for `127.0.0.1` to your nodes hosts file. You can configure the entry with the attributes
```ruby
# GITLAB
default[:gitlab][:hostsfile_entry] = node[:gitlab][:server_name]

# GITLAB CI
default[:gitlab][:ci][:hostsfile_entry] = node[:gitlab][:ci][:server_name]
```

If you want to deactivate this behaviour just set the attribute to empty
```ruby
# GITLAB
default[:gitlab][:hostsfile_entry] = ''

# GITLAB CI
default[:gitlab][:ci][:hostsfile_entry] = ''
```

#### Git

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

#### Ruby

Based on the platform of your node we install ruby through package or with the `ruby_build` cookbook

You can force to install ruby with `ruby_build` by overriding the attribute
```ruby
default[:gitlab][:install_ruby] = '1.9.3-p392'
```


Usage
-----
To install GitLab, GitLab Shell and GitLab CI just add the default recipe to your nodes run_list
```ruby
"recipe[gitlab]"
```

To just install GitLab and GitLab Shell add the `gitlab` recipe to your nodes run_list
```ruby
"recipe[gitlab::gitlab]"
```

To just install GitLab CI add the `gitlab_ci` recipe to your nodes run_list
```ruby
"recipe[gitlab::gitlab_ci]"
```

To install a GitLab Ci Runner add the `gitlab_ci_runner` to your nodes run_list
```ruby
"recipe[gitlab::gitlab_ci_runner]"
```

Vagrant
-----
With Vagrant you can easily Test and Develop GitLab. First you have to install the plugins vagrant-omnibus and vagrant-berkshelf
```shell
vagrant plugin install vagrant-omnibus
vagrant plugin install vagrant-berkshelf
```

For working nfs-support you have to install nfs-kernel-server, nfs-common and portmap on your host machine (e.g. debian/ubuntu)
```shell
sudo apt-get install nfs-kernel-server nfs-common portmap
```

If you want to use VirtualBox-Powered sync folders instead of NFS just remove "nfs: true" from the Vagrantfile. Beware that they are really, really slow.  

Now you are ready to initialize the Vagrant-powered VirtualBox
```shell
vagrant up
```

After the successul run you can reach GitLab under https://10.13.37.23 and GitLab CI under https://10.13.37.42   

The sources are per default at ../cookbook-gitlabhq-src/

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

Credits:
- Gerald L. Hevener Jr. (2012)
- Eric G. Wolfe (2012)
  
License: MIT
