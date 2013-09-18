require_relative 'spec_helper'

describe 'gitlabhq::gitlab' do
  before(:each) do
    @chef_run                       = ChefSpec::ChefRunner.new(CHEF_RUN_OPTIONS)
    @chef_run.node.set[:mysql]      = MYSQL_OPTIONS
    @chef_run.node.set[:postgresql] = POSTGRES_OPTIONS
    @chef_run_with_converge = @chef_run.converge 'gitlabhq::gitlab'
  end

  it "should create the gitlab user" do
    expect(@chef_run).to create_user('git')
  end

  it "should create the gitlab marker directory" do
    expect(@chef_run).to create_directory "#{@chef_run.node[:gitlab][:marker_dir]}"
  end

  %w{
    python::package
    python::pip
  }.each do |recipe|
    it "should include #{recipe} recipe" do
      expect(@chef_run_with_converge).to include_recipe recipe
    end
  end

  it "should install gem packages" do
    @chef_run.node[:gitlab][:gems].each do |package|
      expect(@chef_run_with_converge).to install_gem_package package
    end
  end

  it "should install pygments via python pip" do
    expect(@chef_run_with_converge).to install_python_pip 'pygments'
  end

  it "should include the gitlab shell recipe" do
    expect(@chef_run_with_converge).to include_recipe 'gitlabhq::gitlab_shell'
  end

  it "should clone the gitlab repository" do
    pending
  end

  it "should create a gitlab init script" do
    expect(@chef_run).to create_file '/etc/init.d/gitlab'
  end

  it "should create a gitlab.yml file" do
    expect(@chef_run).to create_file "#{@chef_run.node[:gitlab][:app_home]}/config/gitlab.yml"
  end

  it "should create a database.yml file" do
    expect(@chef_run).to create_file "#{@chef_run.node[:gitlab][:app_home]}/config/database.yml"
  end

  it "should create a directory for the gitlab socket file" do
    expect(@chef_run).to create_directory "#{@chef_run.node[:gitlab][:app_home]}/tmp/sockets"
  end

  it "should create a directory for gitlab satellite repos" do
    expect(@chef_run).to create_directory "#{@chef_run.node[:gitlab][:satellite_path]}"
  end

  it "should create a directory for gitlab backups" do
    expect(@chef_run).to create_directory "#{@chef_run.node[:gitlab][:backup_path]}"
  end

  it "should create a unicorn.rb file" do
    expect(@chef_run).to create_file "#{@chef_run.node[:gitlab][:app_home]}/config/unicorn.rb"
  end

  it "should execute bundle install for the gitlab app" do
    expect(@chef_run).to execute_command(
      "bundle install --without development test postgres --deployment"
    ).with(
      :cwd => @chef_run.node[:gitlab][:app_home],
      :user => @chef_run.node[:gitlab][:user],
      :group => @chef_run.node[:gitlab][:group],
      :creates => "#{@chef_run.node[:gitlab][:app_home]}/vendor/bundle"
    )
  end

  it "should execute rake gitlab:setup" do
    expect(@chef_run_with_converge).to execute_command(
      "bundle exec rake gitlab:setup RAILS_ENV=production force=yes && touch #{@chef_run_with_converge.node[:gitlab][:marker_dir]}/.gitlab-setup"
    ).with(
      :cwd => @chef_run_with_converge.node[:gitlab][:app_home],
      :user => @chef_run_with_converge.node[:gitlab][:user],
      :group => @chef_run_with_converge.node[:gitlab][:group],
      :creates => "#{@chef_run_with_converge.node[:gitlab][:marker_dir]}/.gitlab-setup"
    )
  end

  it "should execute git config username" do
    pending
  end

  it "should execute git config email" do
    pending
  end
end
