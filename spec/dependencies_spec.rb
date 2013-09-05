require_relative 'spec_helper'

describe 'gitlabhq::dependencies' do
  context 'when the node is ubuntu' do
    let (:chef_run)               { ChefSpec::ChefRunner.new(CHEF_RUN_OPTIONS) }
    let (:chef_run_with_converge) { chef_run.converge 'gitlabhq::dependencies' }

    %w{
      build-essential
      readline
      sudo
      openssh
      xml
      zlib
      redisio::install
      redisio::enable
    }.each do |recipe|
      it "should include #{recipe} recipe" do
        expect(chef_run_with_converge).to include_recipe recipe
      end
    end

    %w{
      ruby1.9.1
      ruby1.9.1-dev
      ri1.9.1
      libruby1.9.1
      curl
      wget
      checkinstall
      libxslt-dev
      libsqlite3-dev
      libcurl4-openssl-dev
      libssl-dev
      libmysql++-dev
      libicu-dev
      libc6-dev
      libyaml-dev
      python
      python-dev
    }.each do |package|
      it "should install package #{package}" do
        expect(chef_run_with_converge).to install_package package
      end
    end

    %w{
      bundler
      rake
    }.each do |gem|
      it "should install gem #{gem}" do
        expect(chef_run_with_converge).to install_gem_package gem
      end
    end

    it "should create a symlink for redis-cli" do
      expect(chef_run_with_converge.link("/usr/bin/redis-cli")).to link_to "/usr/local/bin/redis-cli"
    end
  end
end
