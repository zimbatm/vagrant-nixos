module VagrantPlugins
  module Nixos
    class NixosConfigError < Vagrant::Errors::VagrantError
    end

    class Provisioner < Vagrant.plugin("2", :provisioner)
      # This is the method called when the actual provisioning should be
      # done. The communicator is guaranteed to be ready at this point,
      # and any shared folders or networks are already setup.
      #
      # No return value is expected.
      def provision
        conf = if @config.inline
          @config.inline
        elsif @config.path
          File.read(@config.path)
        elsif @config.expression
          "{config, pkgs, ...}: with pkgs; #{@config.expression}"
        else
          raise NixosConfigError, "Mising :path, :inline or :expression"
        end
        Nixos.write_config(machine, "vagrant-provision.nix", conf)
        Nixos.rebuild!(machine, @config)
      end
    end
  end
end
