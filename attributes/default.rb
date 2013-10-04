#
# Cookbook Name:: gitlabhq
# Recipe:: default
#
# Copyright 2013, Wide Eye Labs
#
# MIT License
#

# DEPENDENCIES
case node[:platform]
when 'ubuntu','debian'
  default[:gitlab][:packages] = %w{
    zlib1g-dev libgdbm-dev libreadline-dev
    libncurses5-dev libffi-dev libxml2-dev
    ruby1.9.1 ruby1.9.1-dev ri1.9.1 libruby1.9.1
    curl wget checkinstall libxslt-dev libsqlite3-dev
    libcurl4-openssl-dev libssl-dev libmysql++-dev
    libicu-dev libc6-dev libyaml-dev python python-dev
    libcurl4-gnutls-dev libexpat1-dev gettext libz-dev
  }
when 'redhat','centos','amazon','scientific'
  case node[:platform_version].to_i
  when 5
    default[:gitlab][:packages] = %w{
      curl wget libxslt-devel sqlite-devel openssl-devel
      mysql++-devel libicu-devel glibc-devel libyaml-devel
      python26 python26-devel expat-devel gettext-devel
      libcurl-devel openssl-devel perl-ExtUtils-MakeMaker zlib-devel
    }
  when 6
    default[:gitlab][:packages] = %w{
      curl wget libxslt-devel sqlite-devel openssl-devel
      mysql++-devel libicu-devel glibc-devel
      libyaml-devel python python-devel
      expat-devel gettext-devel libcurl-devel
      perl-ExtUtils-MakeMaker zlib-devel
    }
  end
else
  default[:gitlab][:packages] = %w{
    ruby1.9.1 ruby1.9.1-dev ri1.9.1 libruby1.9.1
    curl wget checkinstall libxslt-dev libsqlite3-dev
    libcurl4-openssl-dev libssl-dev libmysql++-dev
    libicu-dev libc6-dev libyaml-dev python
    python-dev libcurl4-gnutls-dev libexpat1-dev
    gettext libz-dev
  }
end

default[:build_essential][:compiletime] = true
default[:gitlab][:install_ruby] = 'ruby-2.0.0-p247@gitlab'
default[:gitlab][:ruby_dir] = "/usr/local/ruby/#{node[:gitlab][:install_ruby]}/bin"

# GIT
default[:git][:prefix] = "/usr/local"
default[:git][:version] = "1.8.4"
default[:git][:url] = "https://git-core.googlecode.com/files/git-#{node[:git][:version]}.tar.gz"
default[:git][:checksum] = "ed6dbf91b56c1540627563b5e8683fe726dac881ae028f3f17650b88fcb641d7"

# USERS
default[:gitlab][:user] = 'git'
default[:gitlab][:group] = 'git'
default[:gitlab][:home] = '/home/git'
default[:gitlab][:app_home] = "#{node[:gitlab][:home]}/gitlab"
default[:gitlab][:environment] = 'production'
default[:gitlab][:ci][:user] = 'gitlab_ci'
default[:gitlab][:ci][:group] = 'gitlab_ci'
default[:gitlab][:ci][:home] = '/home/gitlab_ci'
default[:gitlab][:ci][:app_home] = "#{node[:gitlab][:ci][:home]}/gitlab-ci"

# GITLAB SHELL
default[:gitlab][:ssh_port] = 22
default[:gitlab][:gitlab_shell_url] = 'https://github.com/gitlabhq/gitlab-shell'
default[:gitlab][:gitlab_shell_branch] = 'v1.5.0'
default[:gitlab][:gitlab_shell_home] = "#{node[:gitlab][:home]}/gitlab-shell"
default[:gitlab][:repos_path] = "#{node[:gitlab][:home]}/repositories"
default[:gitlab][:satellite_path] = "#{node[:gitlab][:home]}/gitlab-satellites"
default[:gitlab][:auth_file] = "#{node[:gitlab][:home]}/.ssh/authorized_keys"
default[:gitlab][:backup_path] = "#{node[:gitlab][:app_home]}/backups"
default[:gitlab][:redis_binary_path] = '/usr/bin/redis-cli'
default[:gitlab][:redis_host] = '127.0.0.1'
default[:gitlab][:redis_port] = 6379
default[:gitlab][:redis_namespace] = 'resque:gitlab'

default[:gitlab][:trust_local_sshkeys] = 'yes'
default[:openssh][:server][:permit_user_environment] = 'yes'

# GITLAB
default[:gitlab][:gitlab_url] = 'https://github.com/gitlabhq/gitlabhq'
default[:gitlab][:gitlab_branch] = 'v5.4.0'
default[:gitlab][:backup_keep_time] = 604800
default[:gitlab][:https] = true
default[:gitlab][:server_name] = 'gitlab.local'
default[:gitlab][:ssl_certificate] = "/etc/nginx/#{node[:fqdn]}.crt"
default[:gitlab][:ssl_certificate_key] = "/etc/nginx/#{node[:fqdn]}.key"
default[:gitlab][:ssl_req] = "/C=US/ST=Several/L=Locality/O=Example/OU=Operations/CN=#{node[:fqdn]}/emailAddress=root@localhost"
default[:gitlab][:gems] = %w{ charlock_holmes bundler rake }
default[:gitlab][:python_packages] = %w{ pygments }
default[:gitlab][:puma_workers] = 1

# BACKUP
default[:gitlab][:backup][:s3_region] = 'us-east-1'
default[:gitlab][:backup][:s3_bucket] = 'gitlab-repo-backups'
default[:gitlab][:backup][:s3_path] = '/backups'
default[:gitlab][:backup][:s3_keep] = 10
default[:gitlab][:backup][:backups_enabled] = true

# CI
default[:gitlab][:ci][:url] = 'https://github.com/gitlabhq/gitlab-ci'
default[:gitlab][:ci][:branch] = 'v3.0.0'
default[:gitlab][:ci][:environment] = 'production'
default[:gitlab][:ci][:server_name] = 'gitlab_ci.local'
