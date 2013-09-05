# There are problems deploying on Redhat provided rubies.
# We'll use Fletcher Nichol's slick ruby_build cookbook to compile a Ruby.
if node[:gitlab][:install_ruby] !~ /package/
  # Include recipe
  include_recipe 'ruby_build'
  
  # Build ruby
  ruby_build_ruby node[:gitlab][:install_ruby]

  # Drop off a profile script (makes ruby bin available for users)
  template "/etc/profile.d/gitlab.sh" do
    source "gitlab.profile.sh.erb"
    owner "root"
    group "root"
    mode 0755
    variables(
        :fqdn => node['fqdn'],
        :ruby_dir => node[:gitlab][:ruby_dir]
    )
  end

  # Set PATH for remainder of recipe
  ENV['PATH'] = "#{node[:gitlab][:ruby_dir]}:#{ENV['PATH']}"
end
