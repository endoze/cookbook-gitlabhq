
# INSTALL DATABASE
case node[:gitlab][:database][:type]
when 'mysql'
  include_recipe 'gitlabhq::database_mysql'
when 'postgres'
  include_recipe 'gitlabhq::database_postgres'
else
  Chef::Log.error "#{node[:gitlab][:database][:type]} is not a valid type. Please use 'mysql' or 'postgres'!"
end
