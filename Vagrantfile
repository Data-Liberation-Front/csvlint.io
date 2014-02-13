# -*- mode: ruby -*-
# vi: set ft=ruby :

require "yaml"
y = YAML.load File.open ".chef/rackspace_secrets.yaml"

nodes = 1

Vagrant.configure("2") do |config|

#  config.butcher.knife_config_file = '.chef/knife.rb'

  nodes.times do |num|
    index = "%02d" % [
        num + 1
    ]

    config.vm.define :"csvlint_#{index}" do |config|
      config.vm.box      = "dummy"
      config.vm.hostname = "csvlint-#{index}"

      config.ssh.private_key_path = "./.chef/id_rsa"
      config.ssh.username         = "root"

      config.vm.provider :rackspace do |rs|
        rs.username        = y["username"]
        rs.api_key         = y["api_key"]
        rs.flavor          = /1GB/
        rs.image           = /Precise/
        rs.public_key_path = "./.chef/id_rsa.pub"
#        rs.auth_url        = "https://lon.identity.api.rackspacecloud.com/v2.0"
        rs.rackspace_region        = :lon
      end

      config.vm.provision :shell, :inline => "curl -L https://www.opscode.com/chef/install.sh | bash"

      config.vm.provision :chef_client do |chef|
        chef.node_name              = "csvlint-#{index}"
        chef.environment            = "csvlint-production"
        chef.chef_server_url        = "https://chef.theodi.org"
        chef.validation_client_name = "chef-validator"
        chef.validation_key_path    = ".chef/chef-validator.pem"
        chef.run_list               = [
            'role[csvlint]',
            'role[csvlint-webnode]'
        ]
      end
    end
  end
end
