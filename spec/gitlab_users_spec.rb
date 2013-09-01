require_relative 'spec_helper'

describe 'gitlabhq::gitlab_users' do
  before(:each) do
    @chef_run                       = ChefSpec::ChefRunner.new(CHEF_RUN_OPTIONS)
    @chef_run.node.set[:mysql]      = MYSQL_OPTIONS
    @chef_run.node.set[:postgresql] = POSTGRES_OPTIONS
    @chef_run_with_converge = @chef_run.converge 'gitlabhq::gitlab_users'
  end

  it "should create the gitlab user" do
    expect(@chef_run).to create_user('git')
  end

  it "should create a marker directory" do
    expect(@chef_run).to create_directory "#{@chef_run.node[:gitlab][:marker_dir]}"
  end

  it "should create a .ssh directory" do
    expect(@chef_run).to create_directory "#{@chef_run.node[:gitlab][:home]}/.ssh"
  end

  it "should create a .bashrc file" do
    expect(@chef_run).to create_file "#{@chef_run.node[:gitlab][:home]}/.bashrc"
  end

  it "should set the git user name" do
    expect(@chef_run).to execute_command(
      "sudo -u git -H bash -l -c \"git config --global user.name Gitlab\""
    ).with(
      :creates => "#{@chef_run.node[:gitlab][:marker_dir]}/.git_config_username"
    )
  end

  it "should set the git email address" do
    expect(@chef_run).to execute_command(
      "sudo -u git -H bash -l -c \"git config --global user.email gitlab@#{@chef_run.node[:fqdn]}\""
    ).with(
      :creates => "#{@chef_run.node[:gitlab][:marker_dir]}/.git_config_email"
    )
  end
end
