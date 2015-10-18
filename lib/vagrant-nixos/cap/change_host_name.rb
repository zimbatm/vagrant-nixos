require 'set'
require 'tempfile'

module VagrantPlugins
  module Nixos
    module Cap
      class ChangeHostName
        include Vagrant::Util

        def self.nix_module(name)
          <<-NIX
            { config, pkgs, ... }:
            {
              networking.hostName = "#{name}";
            }
          NIX
        end

        def self.change_host_name(machine, name)
          if Nixos.write_config(machine, "vagrant-hostname.nix", nix_module(name))
            machine.env[:ui].info "Change host name to #{name}"
          end
        end

      end
    end
  end
end
