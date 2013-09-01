require_relative 'spec_helper'

describe 'gitlabhq::database' do
  before(:each) do
    @chef_run = ChefSpec::ChefRunner.new(CHEF_RUN_OPTIONS)
  end

  context 'when the database type is mysql' do
    it 'it should include the gitlabhq::mysql recipe' do
      @chef_run.node.set[:gitlab][:database][:type] = 'mysql'
      @chef_run.node.set[:mysql] = MYSQL_OPTIONS
      chef_run_with_converge = @chef_run.converge 'gitlabhq::database'
      expect(chef_run_with_converge).to include_recipe 'gitlabhq::mysql'
    end
  end

  context 'when the database type is postgres' do
    it 'it should include the gitlabhq::postgres recipe' do
      @chef_run.node.set[:gitlab][:database][:type] = 'postgres'
      @chef_run.node.set[:postgresql] = POSTGRES_OPTIONS
      chef_run_with_converge = @chef_run.converge 'gitlabhq::database'
      expect(chef_run_with_converge).to include_recipe 'gitlabhq::postgres'
    end
  end
end
