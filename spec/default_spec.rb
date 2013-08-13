require_relative 'spec_helper'

describe 'gitlabhq::default' do
  let (:chef_run) { ChefSpec::ChefRunner.new(CHEF_RUN_OPTIONS).converge 'gitlabhq::default' }
  it 'should include gitlab_shell' do
    expect(chef_run).to include_recipe "gitlabhq::gitlab_shell"
  end
end
