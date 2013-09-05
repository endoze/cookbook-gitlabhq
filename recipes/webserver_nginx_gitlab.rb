# Render nginx default vhost config
template   '/etc/nginx/sites-available/gitlab' do
  owner    'root'
  group    'root'
  mode     0644
  source   'nginx_site.erb'
  variables(
    :server_name         => node[:gitlab][:server_name],
    :app_name            => 'gitlab',
    :app_home            => node[:gitlab][:app_home],
    :https_boolean       => node[:gitlab][:https],
    :ssl_certificate     => node[:gitlab][:webserver][:ssl_certificate],
    :ssl_certificate_key => node[:gitlab][:webserver][:ssl_certificate_key],
    :default_server      =>  true
  )
  notifies :restart, 'service[nginx]', :delayed
end

# Enable gitlab site
nginx_site 'gitlab'
