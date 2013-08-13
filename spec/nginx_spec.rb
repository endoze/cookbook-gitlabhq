require_relative 'spec_helper'

describe 'gitlabhq::nginx' do
  let (:chef_run) { ChefSpec::ChefRunner.new.converge 'gitlabhq' }

  describe 'when https is true' do
    it 'should create an ssl key' do
      pending 'Your recipe examples go here.'
    end
    it 'should create an ssl cert' do
      pending 'Your recipe examples go here.'
    end
  end

  #expect(chef_run).to start_service 'nginx'
end
