# -*- mode: ruby -*-
# vi: set ft=ruby :

defaults = {
  count: 1,
  flavor: /2GB/,
  image: /Trusty/
}

nodesets = [
  {
    name: 'csvlint',
    count: 2,
    chef_env: 'csvlint-prod',
    run_list: [
      'recipe[chef_csvlint]'
    ]
  }
]

require "yaml"
y = YAML.load File.open ".chef/rackspace_secrets.yaml"
# load credentials, uncomment this if running the service locally

Vagrant.configure("2") do |config|

  config.butcher.enabled    = true
  config.butcher.verify_ssl = false

  nodesets.each do |set|
    set = defaults.merge(set)

    set[:count].times do |num|
      index = "%02d" % [num + 1]
      chef_name = "%s-%s" % [
        set[:name].gsub('_', '-'),
        index
      ]

      vagrant_name = "%s_theodi_org_%s" % [
        set[:name],
        index
      ]

      config.vm.define :"#{set[:name]}_theodi_org_#{index}" do |config|
        config.vm.box      = "dummy"
        config.vm.hostname = chef_name

        config.ssh.private_key_path = "./.chef/id_rsa"
        config.ssh.username         = "root"

        config.vm.provider :rackspace do |rs|
          rs.username         = y["username"]
          rs.api_key          = y["api_key"]
          rs.flavor           = set[:flavor]
          rs.image            = set[:image]
          rs.public_key_path  = "./.chef/id_rsa.pub"
          rs.rackspace_region = :lon
        end

        config.vm.provision :shell, :inline => "wget https://opscode.com/chef/install.sh && bash install.sh"

        config.vm.provision :chef_client do |chef|
          chef.node_name              = chef_name
          chef.environment            = "#{set[:chef_env]}"
          chef.chef_server_url        = "https://chef.theodi.org"
          chef.validation_client_name = "chef-validator"
          chef.validation_key_path    = ".chef/chef-validator.pem"
          chef.run_list               = set[:run_list]
        end
      end
    end
  end
end
