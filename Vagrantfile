# -*- mode: ruby -*-
# vi: set ft=ruby :

MEMORY = ENV['GITLAB_VAGRANT_MEMORY'] || '4096'
CORES = ENV['GITLAB_VAGRANT_CORES'] || '4'

Vagrant.configure("2") do |config|
  config.vm.hostname = "gitlabhq-berkshelf"
  config.vm.box = "precise64"
  config.vm.box_url = "http://files.vagrantup.com/precise64.box"
  config.vm.network :private_network, ip: "10.13.37.23"
  config.vm.network :private_network, ip: "10.13.37.42"
  config.berkshelf.berksfile_path = "./Berksfile"
  config.berkshelf.enabled = true

  config.omnibus.chef_version = :latest

  config.vm.provider :virtualbox do |v, override|
    v.customize ["modifyvm", :id, "--memory", MEMORY.to_i]
    v.customize ["modifyvm", :id, "--cpus", CORES.to_i]
  end

  config.vm.synced_folder "../cookbook-gitlabhq-src/", "/home/git", :nfs => true

  config.vm.provision :chef_solo do |chef|
    chef.data_bags_path = "data_bags"
    chef.nfs = true

    chef.add_recipe "phantomjs"
    chef.add_recipe "gitlabhq::default"
    
    chef.json = {
      :phantomjs => {
        :version => '1.8.1'
      },
      :mysql => {
        :server_root_password => 'rootpass',
        :server_debian_password => 'debpass',
        :server_repl_password => 'replpass'
      },
      :gitlab => {
        :environment => 'development',
        :user_create => false,
        :user => 'vagrant',
        :group => 'vagrant',

        :server_name => '10.13.37.23',
        :hostsfile_entry => '',
 
        :ci => {
          :environment => 'development',
          :user_create => false,
          :server_name => '10.13.37.42',
          :allowed_urls => 'https://10.13.37.23',
          :hostsfile_entry => '' 
        },
     
        :shell => {
          :auth_file => '/home/vagrant/.ssh/authorized_keys'
        }
      }
    }
  end
end
