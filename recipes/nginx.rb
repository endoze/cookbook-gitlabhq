ssl_cert_key = node[:gitlab][:ssl_certificate_key]
ssl_cert     = node[:gitlab][:ssl_certificate]
https        = node[:gitlab][:https]
ssl_req      = node[:gitlab][:ssl_req]


service 'nginx' do
  supports :status => true, :restart => true, :reload => true
  action [ :enable, :start ]
end

execute 'create-ssl-key' do
  cwd '/etc/nginx'
  user  'root'
  group 'root'
  umask 0077
  command "openssl genrsa 2048 > #{ssl_cert_key}"
  not_if { !https || File.exists?(ssl_cert_key) }
end

execute 'create-ssl-cert' do
  cwd '/etc/nginx'
  user 'root'
  group 'root'
  umask 0077
  command "openssl req -subj \"#{ssl_req}\" -new -x509 -nodes -sha1 -days 3650 -key #{ssl_cert_key} > #{ssl_cert}"
  not_if { !https || File.exists?(ssl_cert) }
end

# Render nginx default vhost config
template   '/etc/nginx/sites-available/gitlab.conf' do
  owner    'root'
  group    'root'
  mode     0644
  source   'gitlab.conf.erb'
  variables(
    :fqdn                => node[:fqdn],
    :gitlab_app_home     => node[:gitlab][:app_home],
    :https_boolean       => node[:gitlab][:https],
    :ssl_certificate     => node[:gitlab][:ssl_certificate],
    :ssl_certificate_key => node[:gitlab][:ssl_certificate_key]
  )
  notifies :restart, 'service[nginx]'
end

link '/etc/nginx/sites-enabled/gitlab.conf' do
  to '/etc/nginx/sites-available/gitlab.conf'
end
