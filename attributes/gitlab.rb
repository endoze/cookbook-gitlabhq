
# GITLAB
default[:gitlab][:gitlab_url]          = 'git://github.com/gitlabhq/gitlabhq.git'
default[:gitlab][:gitlab_branch]       = 'v5.2.0'
default[:gitlab][:backup_keep_time]    = 604800
default[:gitlab][:https]               = true
default[:gitlab][:ssl_certificate]     = "/etc/nginx/#{node[:fqdn]}.crt"
default[:gitlab][:ssl_certificate_key] = "/etc/nginx/#{node[:fqdn]}.key"
default[:gitlab][:ssl_req]             = "/C=US/ST=Several/L=Locality/O=Example/OU=Operations/CN=#{node[:fqdn]}/emailAddress=root@localhost"
default[:gitlab][:gems]                = %w{ charlock_holmes bundler rake }
default[:gitlab][:python_packages]     = %w{ pygments }
