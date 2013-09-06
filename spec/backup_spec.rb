require 'spec_helper'

describe 'gitlabhq::backup' do
  let(:chef_run)               { ChefSpec::ChefRunner.new(CHEF_RUN_OPTIONS) }
  let(:chef_run_with_converge) { chef_run.converge 'gitlabhq::backup' }

  it 'should include the gitlabhq::backup_aws_s3 recipe' do
    expect(chef_run_with_converge).to include_recipe 'gitlabhq::backup_aws_s3'
  end
end
