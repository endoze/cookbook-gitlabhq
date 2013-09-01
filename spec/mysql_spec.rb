require_relative 'spec_helper'

describe 'gitlabhq::mysql' do
  let (:chef_run)               { ChefSpec::ChefRunner.new(CHEF_RUN_OPTIONS) }
  let (:chef_run_with_converge) { chef_run.converge 'gitlabhq::mysql' }

  it "should create the database" do
    pending
  end

  it "should create the database user" do
    pending
  end

  it "should grant all privileges to user on database" do
    pending
  end
end
