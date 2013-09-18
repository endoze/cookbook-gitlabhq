# VERSIONS (only change if you know what you are doing!)
default[:gitlab][:branch]               = 'v6.0.1'
default[:gitlab][:shell][:branch]       = 'v1.7.1'
default[:gitlab][:ci][:branch]          = 'v3.1.0'
default[:gitlab][:ci][:runner][:branch] = 'master'

# GITLAB
default[:gitlab][:server_name]      = 'gitlab.local'
default[:gitlab][:hostsfile_entry]  = node[:gitlab][:server_name]
default[:gitlab][:https]            = true
default[:gitlab][:user]             = 'git'
default[:gitlab][:user_create]      = true
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

# GITLAB BACKUP
default[:gitlab][:backup][:path]             = "#{node[:gitlab][:app_home]}/backups"
default[:gitlab][:backup][:keep_time]        = 604800
default[:gitlab][:backup][:remote][:handler] = []

# GITLAB BACKUP AWS HANDLER
default[:gitlab][:backup][:remote][:aws_s3][:region] = 'us-east-1'
default[:gitlab][:backup][:remote][:aws_s3][:bucket] = 'gitlab-repo-backups'
default[:gitlab][:backup][:remote][:aws_s3][:path]   = '/backups'
default[:gitlab][:backup][:remote][:aws_s3][:keep]   = 10

# GITLAB CI
default[:gitlab][:ci][:server_name]      = 'gitlab_ci.local'
default[:gitlab][:ci][:hostsfile_entry]  = node[:gitlab][:ci][:server_name]
default[:gitlab][:ci][:user]             = node[:gitlab][:user]
default[:gitlab][:ci][:user_create]      = node[:gitlab][:user_create]
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

# GITLAB CI RUNNER
default[:gitlab][:ci][:runner][:user]             = node[:gitlab][:user]
default[:gitlab][:ci][:runner][:user_create]      = node[:gitlab][:user_create]
default[:gitlab][:ci][:runner][:user_shell]       = node[:gitlab][:user_shell]
default[:gitlab][:ci][:runner][:user_manage_home] = node[:gitlab][:user_manage_home]
default[:gitlab][:ci][:runner][:group]            = node[:gitlab][:group]
default[:gitlab][:ci][:runner][:home]             = node[:gitlab][:home]
default[:gitlab][:ci][:runner][:app_home]         = "#{node[:gitlab][:ci][:home]}/gitlab-ci-runner"
default[:gitlab][:ci][:runner][:marker_dir]       = "#{node[:gitlab][:ci][:home]}/.markers"
default[:gitlab][:ci][:runner][:url]              = 'https://github.com/gitlabhq/gitlab-ci-runner'


# WEBSERVER
default[:gitlab][:webserver][:type]                = 'nginx'
default[:gitlab][:webserver][:ssl_certificate]     = "/etc/#{node[:gitlab][:webserver][:type]}/#{node[:fqdn]}.crt"
default[:gitlab][:webserver][:ssl_certificate_key] = "/etc/#{node[:gitlab][:webserver][:type]}/#{node[:fqdn]}.key"
default[:gitlab][:webserver][:ssl_req]             = "/C=US/ST=Several/L=Locality/O=Example/OU=Operations/CN=#{node[:fqdn]}/emailAddress=root@localhost"

# BUILD_ESSENTIAL 
default[:build_essential][:compiletime] = true

# GIT
default[:gitlab][:git][:include_recipe] = "default"

# GIT::SOURCE
default[:git][:prefix] = "/usr/local"
default[:git][:version] = "1.8.4"
default[:git][:url] = "https://git-core.googlecode.com/files/git-#{node[:git][:version]}.tar.gz"
default[:git][:checksum] = "ed6dbf91b56c1540627563b5e8683fe726dac881ae028f3f17650b88fcb641d7"

# OPENSSH 
default[:openssh][:server][:permit_user_environment] = 'yes'

# RUBY
case node[:platform]
  when 'redhat','centos','scientific','amazon'
    default[:gitlab][:install_ruby] = '1.9.3-p392'
    default[:gitlab][:ruby_dir]     = "/usr/local/ruby/#{node[:gitlab][:install_ruby]}/bin"
  else
    default[:gitlab][:install_ruby] = 'package'
end

# REQUIRED PACKAGES BASED ON PLATFORM
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
