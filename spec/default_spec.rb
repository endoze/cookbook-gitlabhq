require_relative 'spec_helper'

describe 'gitlabhq::default' do
  before(:each) do
    @chef_run                       = ChefSpec::ChefRunner.new(CHEF_RUN_OPTIONS)
    @chef_run.node.set[:mysql]      = MYSQL_OPTIONS
    @chef_run.node.set[:postgresql] = POSTGRES_OPTIONS
    @chef_run_with_converge = @chef_run.converge 'gitlabhq::default'
  end

  %w{
    gitlabhq::dependencies
    gitlabhq::gitlab_users
    gitlabhq::gitlab_shell
    gitlabhq::database
    gitlabhq::gitlab
    gitlabhq::nginx
  }.each do |recipe|
    it "should include recipe #{recipe}" do
      expect(@chef_run_with_converge).to include_recipe recipe
    end
  end
end

