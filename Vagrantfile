# -*- mode: ruby -*-
# vi: set ft=ruby :

MEMORY = ENV['GITLAB_VAGRANT_MEMORY'] || '512'
CORES = ENV['GITLAB_VAGRANT_CORES'] || '1'

Vagrant.configure("2") do |config|
  config.vm.box = "precise64"
  config.vm.box_url = "http://files.vagrantup.com/precise64.box"
  config.berkshelf.berksfile_path = "./Berksfile"
  config.berkshelf.enabled = true

  config.vm.provision :shell, :path => "bootstrap.sh"

  config.vm.provider :virtualbox do |v, override|
    v.customize ["modifyvm", :id, "--memory", MEMORY.to_i]
    v.customize ["modifyvm", :id, "--cpus", CORES.to_i]
  end

  config.vm.define "app" do |app|
    app.vm.hostname = "gitlab-app-server-berkshelf"
    app.vm.network :private_network, ip: "33.33.33.20"
    app.vm.provision :chef_solo do |chef|
      chef.data_bags_path = 'data_bags'
      chef.json = {
        :gitlab => {
          :ci => {
            :allowed_urls => ['https://gitlab.local']
          }
        },
        :authorization => {
          :sudo => {
            :groups => ["admin", "wheel", "sysadmin"],
            :users => ["vagrant"],
            :passwordless => true
          }
        }
      }

      chef.run_list = [
        "recipe[sudo]",
        "recipe[gitlabhq::gitlab]",
        "recipe[gitlabhq::ci]",
        "recipe[gitlabhq::nginx]",
        "recipe[gitlabhq::backup]"
      ]
    end
  end

  config.vm.define "db" do |db|
    db.vm.hostname = "gitlab-database-server-berkshelf"
    db.vm.network :private_network, ip: "33.33.33.21"
    db.vm.provision :chef_solo do |chef|
      chef.data_bags_path = 'data_bags'
      chef.json = {
        :mysql => {
          :server_root_password => 'rootpass',
          :server_debian_password => 'debpass',
          :server_repl_password => 'replpass',
          :bind_address => '33.33.33.21'
        },
        :authorization => {
          :sudo => {
            :groups => ["admin", "wheel", "sysadmin"],
            :users => ["vagrant"],
            :passwordless => true
          }
        }
      }

      chef.run_list = [
        "recipe[gitlabhq::database]",
        "recipe[gitlabhq::backup]"
      ]
    end
  end
end
