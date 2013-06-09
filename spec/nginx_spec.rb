require 'chefspec'

describe 'gitlabhq::nginx' do
  let (:chef_run) { ChefSpec::ChefRunner.new.converge 'gitlabhq::nginx' }

  describe 'when https is true' do
    it 'should create an ssl key' do
      expect(chef_run).to create_file "/etc/nginx/#{node[:gitlab][:ssl_certificate_key]}"
    end
    it 'should create an ssl cert' do
      expect(chef_run).to create_file "/etc/nginx/#{node[:gitlab][:ssl_certificate]}"
    end
  end

  #expect(chef_run).to start_service 'nginx'
end
