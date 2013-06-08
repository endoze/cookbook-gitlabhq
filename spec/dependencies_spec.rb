require 'chefspec'

describe 'gitlabhq::dependencies' do
  let (:chef_run) { ChefSpec::ChefRunner.new.converge 'gitlabhq::dependencies' }
  it 'should do something' do
    pending 'Your recipe examples go here.'
  end
end
