
# INSTALL DATABASE
case node[:gitlab][:database][:type]
when 'mysql'
  include_recipe 'gitlabhq::mysql'
when 'postgres'
  include_recipe 'gitlabhq::postgres'
else
  Chef::Log.error "#{node[:gitlab][:database][:type]} is not a valid type. Please use 'mysql' or 'postgres'!"
end
