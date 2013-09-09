include_recipe 'gitlabhq::dependencies'

# Create Gitlab CI Runner user
user node[:gitlab][:ci][:runner][:user] do
  home     node[:gitlab][:ci][:runner][:home]
  shell    node[:gitlab][:ci][:runner][:user_shell]
  supports :manage_home => node[:gitlab][:ci][:runner][:user_manage_home]
end

# Create directory to store markers in
directory node[:gitlab][:ci][:runner][:marker_dir] do
  owner   node[:gitlab][:ci][:runner][:user]
  group   node[:gitlab][:ci][:runner][:group]
  mode    0700
end

# Clone gitlab-ci-runner
git node[:gitlab][:ci][:runner][:app_home] do
  repository  node[:gitlab][:ci][:runner][:url]
  reference   node[:gitlab][:ci][:runner][:branch]
  action      :checkout
  user        node[:gitlab][:ci][:runner][:user]
  group       node[:gitlab][:ci][:runner][:group]
end

# Render gitlab ci runner init script
template '/etc/init.d/gitlab_ci_runner' do
  owner  'root'
  group  'root'
  mode   0755
  source 'gitlab_ci_runner.init.erb'
  variables(
    :app_home    => node[:gitlab][:ci][:runner][:app_home],
    :app_user    => node[:gitlab][:ci][:runner][:user]
  )
end

# Start runner on boot
execute 'gitlab-ci-runner-on-boot' do
  command "update-rc.d gitlab_ci_runner defaults 21"
end

# Install gems with bundle install
execute 'gitlab-ci-runner-bundle-install' do
  command "bundle install --deployment"
  cwd     node[:gitlab][:ci][:runner][:app_home]
  user    node[:gitlab][:ci][:runner][:user]
  group   node[:gitlab][:ci][:runner][:group]
  environment({ 'LANG' => 'en_US.UTF-8', 'LC_ALL' => 'en_US.UTF-8' })
  creates "#{node[:gitlab][:ci][:runner][:app_home]}/vendor/bundle"
end
