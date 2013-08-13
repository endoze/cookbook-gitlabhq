require_relative 'spec_helper'

describe 'gitlabhq::mysql' do
  let (:chef_run) { ChefSpec::ChefRunner.new(CHEF_RUN_OPTIONS).converge 'gitlabhq::mysql' }
  it 'should do something' do
    pending 'Your recipe examples go here.'
  end
end
