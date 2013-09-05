include_recipe "gitlabhq::webserver"

# Render nginx vhost config
template   '/etc/nginx/sites-available/gitlab_ci' do
  owner    'root'
  group    'root'
  mode     0644
  source   'nginx_site.erb'
  variables(
    :server_name         => node[:gitlab][:ci][:server_name],
    :app_name            => 'gitlab-ci',
    :app_home            => node[:gitlab][:ci][:app_home],
    :https_boolean       => node[:gitlab][:https],
    :ssl_certificate     => node[:gitlab][:webserver][:ssl_certificate],
    :ssl_certificate_key => node[:gitlab][:webserver][:ssl_certificate_key]
  )
  notifies :restart, 'service[nginx]', :delayed
end

# Enable gitlab ci site
nginx_site 'gitlab_ci'
