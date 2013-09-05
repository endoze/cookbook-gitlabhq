case node[:gitlab][:git][:include_recipe]
  when 'default'
    include_recipe 'git'
  when 'source'
    include_recipe 'git::source'
end
