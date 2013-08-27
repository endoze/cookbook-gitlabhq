require_relative 'spec_helper'

describe 'gitlabhq::mysql' do
  let (:chef_run)               { ChefSpec::ChefRunner.new(CHEF_RUN_OPTIONS) }
  let (:chef_run_with_converge) { chef_run.converge 'gitlabhq::default' }
end
