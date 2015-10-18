begin
  require "vagrant"
rescue LoadError
  raise "The Nixos plugin must be run within Vagrant."
end

# This is a sanity check to make sure no one is attempting to install
# this into an early Vagrant version.
if Vagrant::VERSION < "1.6.4"
  raise "The Nixos plugin is only compatible with Vagrant 1.6.4+"
end

module VagrantPlugins
  module Nixos

    @@nix_imports = {}

    class Plugin < Vagrant.plugin("2")
      name "nixos"
      description <<-DESC
      This plugin add nixos provisioning capabilities.
      DESC

      config :nixos, :provisioner do
        require_relative "config"
        Config
      end
      
      provisioner :nixos do
        require_relative "provisioner"
        Provisioner
      end

    end

  end
end
