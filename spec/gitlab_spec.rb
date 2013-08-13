require 'spec_helper'

describe 'gitlabhq::gitlab' do
  let (:chef_run) { ChefSpec::ChefRunner.new.converge 'gitlabhq::gitlab' }
  it 'should do something' do
    pending 'Your recipe examples go here.'
  end
end
