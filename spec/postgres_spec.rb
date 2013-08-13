require_relative 'spec_helper'

describe 'gitlabhq::postgres' do
  let (:chef_run) { ChefSpec::ChefRunner.new.converge 'gitlabhq::postgres' }
  it 'should do something' do
    pending 'Your recipe examples go here.'
  end
end
