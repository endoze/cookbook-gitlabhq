require_relative 'spec_helper'

describe 'gitlabhq::gitlab_shell' do
  let (:chef_run)               { ChefSpec::ChefRunner.new(CHEF_RUN_OPTIONS) }
  let (:chef_run_with_converge) { chef_run.converge 'gitlabhq::gitlab_shell' }

  it "should clone the gitlab shell repository" do
    pending
  end

  it "should create a config.yml file for gitlab-shell" do
    expect(chef_run_with_converge).to create_file "#{chef_run_with_converge.node[:gitlab][:shell][:app_home]}/config.yml"
  end

  it "should execute the install script for gitlab-shell" do
    expect(chef_run).to execute_command("./bin/install && touch #{chef_run_with_converge.node[:gitlab][:marker_dir]}/.gitlab-shell-setup").with(
      :cwd => chef_run_with_converge.node[:gitlab][:shell][:app_home],
      :user => chef_run_with_converge.node[:gitlab][:user],
      :group => chef_run_with_converge.node[:gitlab][:group],
      :creates => "#{chef_run_with_converge.node[:gitlab][:marker_dir]}/.gitlab-shell-setup"
    )
  end

end
