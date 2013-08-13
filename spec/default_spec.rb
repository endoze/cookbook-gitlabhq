require 'spec_helper'

describe 'gitlabhq::default' do
  let (:chef_run) { ChefSpec::ChefRunner.new.converge described_cookbook }
  it 'should include gitlab_shell' do
    expect(chef_run).to include_recipe "#{described_cookbook}::gitlab_shell"
  end
end
