case node[:gitlab][:webserver][:type]
  when 'nginx'
    include_recipe 'gitlabhq::webserver_nginx'
end
