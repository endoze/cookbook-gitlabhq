
# Render nginx default vhost config
template   "/etc/nginx/sites-available/gitlab.conf" do
  owner    'root'
  group    'root'
  mode     0644
  source   'gitlab.conf.erb'
  notifies :restart, 'service[nginx]'
  variables(
    :fqdn                => node[:fqdn],
    :gitlab_app_home     => node[:gitlab][:app_home],
    :https_boolean       => node[:gitlab][:https],
    :ssl_certificate     => node[:gitlab][:ssl_certificate],
    :ssl_certificate_key => node[:gitlab][:ssl_certificate_key]
  )
end

link "/etc/nginx/sites-enabled/gitlab.conf" do
  to '/etc/nginx/sites-available/gitlab.conf'
end
