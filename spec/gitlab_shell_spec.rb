require 'chefspec'

describe 'gitlabhq::gitlab_shell' do
  let (:chef_run) { ChefSpec::ChefRunner.new.converge 'gitlabhq::gitlab_shell' }
  it 'should do something' do
    pending 'Your recipe examples go here.'
  end
end
