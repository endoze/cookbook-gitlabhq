require_relative 'spec_helper'

describe 'gitlabhq::nginx' do
  context 'when https is true' do
    before(:each) do
      @chef_run                       = ChefSpec::ChefRunner.new(CHEF_RUN_OPTIONS)
      @chef_run.node.set[:mysql]      = MYSQL_OPTIONS
      @chef_run.node.set[:postgresql] = POSTGRES_OPTIONS
      @chef_run_with_converge = @chef_run.converge 'gitlabhq::nginx'

      @ssl_req      = @chef_run.node[:gitlab][:ssl_req]
      @ssl_cert_key = @chef_run.node[:gitlab][:ssl_certificate_key]
      @ssl_cert     = @chef_run.node[:gitlab][:ssl_certificate]
    end

    it 'should create an ssl key' do
      expect(@chef_run).to execute_command "openssl genrsa 2048 > #{@ssl_cert_key}"
    end

    it 'should create an ssl cert' do
      expect(@chef_run).to execute_command "openssl req -subj \"#{@ssl_req}\" -new -x509 -nodes -sha1 -days 3650 -key #{@ssl_cert_key} > #{@ssl_cert}"
    end

    it "should create an nginx config file for gitlab" do
      expect(@chef_run).to create_file '/etc/nginx/sites-available/gitlab.conf'
    end

    it "should symlink the gitlab nginx config to sites-enabled" do
      expect(@chef_run.link('/etc/nginx/sites-enabled/gitlab.conf')).to link_to '/etc/nginx/sites-available/gitlab.conf'
    end
  end
end
