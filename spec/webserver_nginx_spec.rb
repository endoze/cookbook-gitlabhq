require_relative 'spec_helper'

describe 'gitlabhq::webserver_nginx' do
  context 'when https is true' do
    before(:each) do
      @chef_run                       = ChefSpec::ChefRunner.new(CHEF_RUN_OPTIONS)
      @chef_run.node.set[:mysql]      = MYSQL_OPTIONS
      @chef_run.node.set[:postgresql] = POSTGRES_OPTIONS
      @chef_run_with_converge = @chef_run.converge 'gitlabhq::webserver_nginx'

      @ssl_req      = @chef_run.node[:gitlab][:webserver][:ssl_req]
      @ssl_cert_key = @chef_run.node[:gitlab][:webserver][:ssl_certificate_key]
      @ssl_cert     = @chef_run.node[:gitlab][:webserver][:ssl_certificate]
    end

    it 'should create an ssl key' do
      expect(@chef_run).to execute_command "openssl genrsa 2048 > #{@ssl_cert_key}"
    end

    it 'should create an ssl cert' do
      expect(@chef_run).to execute_command "openssl req -subj \"#{@ssl_req}\" -new -x509 -nodes -sha1 -days 3650 -key #{@ssl_cert_key} > #{@ssl_cert}"
    end
  end
end
