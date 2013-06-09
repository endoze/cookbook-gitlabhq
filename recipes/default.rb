#
# Cookbook Name:: gitlabhq
# Recipe:: default
#
# Copyright 2013, Wide Eye Labs
#
# MIT License
#

include_recipe 'gitlabhq::dependencies'

include_recipe 'gitlabhq::gitlab_users'

include_recipe 'gitlabhq::gitlab_shell'

include_recipe 'gitlabhq::database'

include_recipe 'gitlabhq::gitlab'

include_recipe 'gitlabhq::nginx'

# Start gitlab and nginx service
%w{ nginx }.each do |svc|
  service svc do
    action [ :enable, :start]
  end
end

