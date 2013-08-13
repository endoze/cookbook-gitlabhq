require_relative 'spec_helper'

describe 'gitlabhq::database' do
  let (:chef_run) { ChefSpec::ChefRunner.new.converge 'gitlabhq::database' }
  it 'should do something' do
    pending 'Your recipe examples go here.'
  end
end
