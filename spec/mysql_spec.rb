require 'spec_helper'

describe 'gitlabhq::mysql' do
  let (:chef_run) { ChefSpec::ChefRunner.new.converge 'gitlabhq::mysql' }
  it 'should do something' do
    pending 'Your recipe examples go here.'
  end
end
