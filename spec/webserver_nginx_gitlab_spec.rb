require_relative 'spec_helper'

describe 'gitlabhq::webserver_nginx_gitlab' do
  before(:each) do
    @chef_run                       = ChefSpec::ChefRunner.new(CHEF_RUN_OPTIONS)
    @chef_run.node.set[:mysql]      = MYSQL_OPTIONS
    @chef_run.node.set[:postgresql] = POSTGRES_OPTIONS
    @chef_run_with_converge = @chef_run.converge 'gitlabhq::webserver_nginx_gitlab'
  end

  it "should create an nginx config file for gitlab" do
    expect(@chef_run).to create_file '/etc/nginx/sites-available/gitlab'
  end

  it "should execute nxensite gitlab" do 
    expect(@chef_run.execute("nxensite gitlab")).to notify("service[nginx]", "reload")
  end
end
