# -*- mode: ruby -*-
# vi: set ft=ruby :

MEMORY = ENV['GITLAB_VAGRANT_MEMORY'] || '1024'
CORES = ENV['GITLAB_VAGRANT_CORES'] || '1'

Vagrant.configure("2") do |config|
  config.vm.hostname = "gitlabhq-berkshelf"
  config.vm.box = "precise64"
  config.vm.box_url = "http://files.vagrantup.com/precise64.box"
  config.vm.network :private_network, ip: "33.33.33.10"
  config.ssh.max_tries = 40
  config.ssh.timeout   = 120
  config.berkshelf.berksfile_path = "./Berksfile"
  config.berkshelf.enabled = true

  config.vm.provision :shell, :inline => "sudo apt-get update && sudo apt-get install --yes build-essential && gem install chef --version '~> 11' --no-rdoc --no-ri --conservative"

  config.vm.provider :virtualbox do |v, override|
    v.customize ["modifyvm", :id, "--memory", MEMORY.to_i]
    v.customize ["modifyvm", :id, "--cpus", CORES.to_i]
  end

  config.vm.provision :chef_solo do |chef|
    chef.add_recipe "sudo"
    chef.add_recipe "gitlabhq::default"
    chef.json = {
      :mysql => {
        :server_root_password => 'rootpass',
        :server_debian_password => 'debpass',
        :server_repl_password => 'replpass'
      },
      :authorization => {
        :sudo => {
          :groups => ["admin", "wheel", "sysadmin"],
          :users => ["vagrant"],
          :passwordless => true
        }
      }
    }
  end
end
