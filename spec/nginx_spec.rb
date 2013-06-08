require 'chefspec'

describe 'gitlabhq::nginx' do
  let (:chef_run) { ChefSpec::ChefRunner.new.converge 'gitlabhq::nginx' }
  it 'should do something' do
    pending 'Your recipe examples go here.'
  end
end
