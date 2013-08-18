require_relative 'spec_helper'

describe 'gitlabhq::default' do
  let (:chef_run)               { ChefSpec::ChefRunner.new(CHEF_RUN_OPTIONS) }
  let (:chef_run_with_converge) { chef_run.converge 'gitlabhq::default' }

  %w{
    gitlabhq::dependencies
    gitlabhq::gitlab_users
    gitlabhq::gitlab_shell
    gitlabhq::database
    gitlabhq::gitlab
    gitlabhq::nginx }.each do |recipe|
      it "should include recipe #{recipe}" do
        expect(chef_run_with_converge).to include_recipe recipe
      end
    end

  it "should set nginx service to start on boot" do
    expect(chef_run_with_converge).to set_service_to_start_on_boot 'nginx'
  end

  it "should start nginx service" do
    expect(chef_run_with_converge).to start_service 'nginx'
  end
end

