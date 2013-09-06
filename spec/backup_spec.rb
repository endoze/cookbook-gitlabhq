require 'spec_helper'

describe 'gitlabhq::backup' do
  let(:chef_run)               { ChefSpec::ChefRunner.new(CHEF_RUN_OPTIONS) }
  let(:chef_run_with_converge) { chef_run.converge 'gitlabhq::backup' }

  context 'when backups are enabled' do
    it 'should include the backup recipe' do
      chef_run.node.set[:gitlab][:backup][:backups_enabled] = true
      expect(chef_run_with_converge).to include_recipe 'backup'
    end

    it 'should write out a backup config file' do
      expect(chef_run_with_converge).to create_file  '/opt/backup/config.rb'
    end

    %w{ libxml2-dev libxslt1-dev }.each do |pkg|
      it "should install #{pkg} as a system package" do
        expect(chef_run_with_converge).to install_package pkg
      end
    end

    it 'should install the backup gem' do
      expect(chef_run_with_converge).to install_gem_package 'backup'
    end

    %w{ net-ssh net-scp excon fog}.each do |gem|
      it "should install #{gem} as a gem" do
        expect(chef_run_with_converge).to install_gem_package gem
      end
    end

    it 'should generate the gitlab repo backup model' do
      pending
    end

    it 'should generate the gitlab database backup model' do
      pending
    end
  end

  context 'when backups are not enabled' do
    it 'should not include the backup recipe' do
      chef_run.node.set[:gitlab][:backup][:backups_enabled] = false
      expect(chef_run_with_converge).not_to include_recipe 'backup'
    end
  end
end
