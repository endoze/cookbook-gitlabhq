
# INSTALL GITLAB SHELL
git node[:gitlab][:gitlab_shell_home] do
  repository node[:gitlab][:gitlab_shell_url]
  reference  node[:gitlab][:gitlab_shell_branch]
  action     :checkout
  user       node[:gitlab][:user]
  group      node[:gitlab][:group]
end

template "#{node[:gitlab][:gitlab_shell_home]}/config.yml" do
  owner  node[:gitlab][:user]
  group  node[:gitlab][:group]
  mode   0644
  variables(
    :git_user         => node[:gitlab][:gitlab_shell_user],
    :repos_path       => node[:gitlab][:repos_path],
    :auth_file        => node[:gitlab][:auth_file],
    :redis_binary     => node[:gitlab][:redis_binary_path],
    :redis_host       => node[:gitlab][:redis_host],
    :redis_port       => node[:gitlab][:redis_port],
    :redis_socket     => node[:gitlab][:redis_socket],
    :redis_namespace  => node[:gitlab][:redis_namespace]
  )
end

execute 'gitlab-shell-install' do
  command "./bin/install && touch #{node[:gitlab][:marker_dir]}/.gitlab-shell-setup"
  cwd     node[:gitlab][:gitlab_shell_home]
  user    node[:gitlab][:user]
  group   node[:gitlab][:group]
  creates "#{node[:gitlab][:marker_dir]}/.gitlab-shell-setup"
end
