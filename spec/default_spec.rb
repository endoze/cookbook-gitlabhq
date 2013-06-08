require 'chefspec'

describe 'gitlabhq::default' do
  let (:chef_run) { ChefSpec::ChefRunner.new.converge 'gitlabhq::default' }
  it 'should do something' do
    pending 'Your recipe examples go here.'
  end
end
