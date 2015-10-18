begin
  require "vagrant"
rescue LoadError
  raise "The Nixos plugin must be run within Vagrant."
end

# This is a sanity check to make sure no one is attempting to install
# this into an early Vagrant version.
if Vagrant::VERSION < "1.2.0"
  raise "The Nixos plugin is only compatible with Vagrant 1.2+"
end

module VagrantPlugins
  module Nixos

    @@nix_imports = {}

    class Plugin < Vagrant.plugin("2")
      name "nixos"
      description <<-DESC
      This plugin installs nixos guest capabilities.
      DESC

      guest("nixos", "linux") do
        require_relative "guest"
        Guest
      end

      guest_capability("nixos", "configure_networks") do
        require_relative "cap/configure_networks"
        Cap::ConfigureNetworks
      end

      guest_capability("nixos", "change_host_name") do
        require_relative "cap/change_host_name"
        Cap::ChangeHostName
      end

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
