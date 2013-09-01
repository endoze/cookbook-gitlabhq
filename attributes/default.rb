
# DEPENDENCIES
case node[:platform]
when 'ubuntu','debian'
  default[:gitlab][:packages] = %w{
    zlib1g-dev libgdbm-dev libreadline-dev
    libncurses5-dev libffi-dev libxml2-dev
    ruby1.9.1 ruby1.9.1-dev ri1.9.1 libruby1.9.1
    curl wget checkinstall libxslt-dev libsqlite3-dev
    libcurl4-openssl-dev libssl-dev libmysql++-dev
    libicu-dev libc6-dev libyaml-dev nginx python python-dev
    libcurl4-gnutls-dev libexpat1-dev gettext libz-dev
  }
when 'redhat','centos','amazon','scientific'
  case node[:platform_version].to_i
  when 5
    default[:gitlab][:packages] = %w{
      curl wget libxslt-devel sqlite-devel openssl-devel
      mysql++-devel libicu-devel glibc-devel libyaml-devel
      nginx python26 python26-devel expat-devel gettext-devel
      libcurl-devel openssl-devel perl-ExtUtils-MakeMaker zlib-devel
    }
  when 6
    default[:gitlab][:packages] = %w{
      curl wget libxslt-devel sqlite-devel openssl-devel
      mysql++-devel libicu-devel glibc-devel
      libyaml-devel nginx python python-devel
      expat-devel gettext-devel libcurl-devel
      perl-ExtUtils-MakeMaker zlib-devel
    }
  end
else
  default[:gitlab][:packages] = %w{
    ruby1.9.1 ruby1.9.1-dev ri1.9.1 libruby1.9.1
    curl wget checkinstall libxslt-dev libsqlite3-dev
    libcurl4-openssl-dev libssl-dev libmysql++-dev
    libicu-dev libc6-dev libyaml-dev nginx python
    python-dev libcurl4-gnutls-dev libexpat1-dev
    gettext libz-dev
  }
end

default[:build_essential][:compiletime] = true
default[:nginx][:default_site_enabled] = false
default[:gitlab][:install_ruby] = '1.9.3-p392'
default[:gitlab][:ruby_dir]     = "/usr/local/ruby/#{node[:gitlab][:install_ruby]}/bin"

# GIT
default[:git][:prefix] = "/usr/local"
default[:git][:version] = "1.8.4"
default[:git][:url] = "https://git-core.googlecode.com/files/git-#{node[:git][:version]}.tar.gz"
default[:git][:checksum] = "ed6dbf91b56c1540627563b5e8683fe726dac881ae028f3f17650b88fcb641d7"

# DATABASE
default[:gitlab][:database][:type]     = 'mysql'
default[:gitlab][:database][:adapter]  =  default[:gitlab][:database][:type] == 'mysql' ? 'mysql2' : 'postgresql'
default[:gitlab][:database][:encoding] = default[:gitlab][:database][:type] == 'mysql' ? 'utf8' : 'unicode'
default[:gitlab][:database][:host]     = 'localhost'
default[:gitlab][:database][:pool]     = 5
default[:gitlab][:database][:database] = 'gitlab'
default[:gitlab][:database][:username] = 'gitlab'

# GITLAB USER
default[:gitlab][:user]        = 'git'
default[:gitlab][:group]       = 'git'
default[:gitlab][:home]        = '/home/git'
default[:gitlab][:app_home]    = "#{node[:gitlab][:home]}/gitlab"
default[:gitlab][:environment] = 'production'
default[:gitlab][:marker_dir]  = "#{node[:gitlab][:home]}/.markers"

# GITLAB SHELL
default[:gitlab][:ssh_port]            = 22
default[:gitlab][:gitlab_shell_url]    = 'https://github.com/gitlabhq/gitlab-shell'
default[:gitlab][:gitlab_shell_branch] = 'v1.5.0'
default[:gitlab][:gitlab_shell_home]   = "#{node[:gitlab][:home]}/gitlab-shell"
default[:gitlab][:gitlab_shell_user]   = 'git'
default[:gitlab][:repos_path]          = "#{node[:gitlab][:home]}/repositories"
default[:gitlab][:satellite_path]      = "#{node[:gitlab][:home]}/gitlab-satellites"
default[:gitlab][:auth_file]           = "#{node[:gitlab][:home]}/.ssh/authorized_keys"
default[:gitlab][:backup_path]         = "#{node[:gitlab][:app_home]}/backups"
default[:gitlab][:redis_binary_path]   = '/usr/bin/redis-cli'
default[:gitlab][:redis_host]          = '127.0.0.1'
default[:gitlab][:redis_port]          = 6379
default[:gitlab][:redis_namespace]     = 'resque:gitlab'

default[:gitlab][:trust_local_sshkeys] = 'yes'
default[:openssh][:server][:permit_user_environment] = 'yes'

# GITLAB
default[:gitlab][:gitlab_url]          = 'https://github.com/gitlabhq/gitlabhq'
default[:gitlab][:gitlab_branch]       = 'v5.4.0'
default[:gitlab][:backup_keep_time]    = 604800
default[:gitlab][:https]               = true
default[:gitlab][:ssl_certificate]     = "/etc/nginx/#{node[:fqdn]}.crt"
default[:gitlab][:ssl_certificate_key] = "/etc/nginx/#{node[:fqdn]}.key"
default[:gitlab][:ssl_req]             = "/C=US/ST=Several/L=Locality/O=Example/OU=Operations/CN=#{node[:fqdn]}/emailAddress=root@localhost"
default[:gitlab][:gems]                = %w{ charlock_holmes bundler rake }
default[:gitlab][:python_packages]     = %w{ pygments }

# BACKUP
default[:gitlab][:backup][:s3_region] = 'us-east-1'
default[:gitlab][:backup][:s3_bucket] = 'gitlab-repo-backups'
default[:gitlab][:backup][:s3_path]   = '/backups'
default[:gitlab][:backup][:s3_keep]   = 10
