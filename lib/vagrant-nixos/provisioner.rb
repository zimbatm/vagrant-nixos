module VagrantPlugins
  module Nixos
    NixosConfigError = Class.new(Vagrant::Errors::VagrantError)

    CONFIG_HEADER = "# This file is overwritten by the vagrant-nixos plugin\n"

    class Provisioner < Vagrant.plugin("2", :provisioner)
      # This is the method called when the actual provisioning should be
      # done. The communicator is guaranteed to be ready at this point,
      # and any shared folders or networks are already setup.
      #
      # No return value is expected.
      def provision
        prov = if config.inline
          config.inline
        elsif config.path
          File.read(config.path)
        elsif config.expression
          "{config, pkgs, ...}: with pkgs; #{@config.expression}"
        else
          "{}"
        end
        write_config('vagrant-provision.nix', prov)
        rebuild!
      end

      protected

      # just do nixos-rebuild
      def rebuild!
        prepare!

        # rebuild
        rebuild_cmd = "nixos-rebuild switch"
        rebuild_cmd = "#{rebuild_cmd} -I nixos-config=/etc/nixos/vagrant.nix" if config.include
        rebuild_cmd = "NIX_PATH=#{config.NIX_PATH}:$NIX_PATH #{rebuild_cmd}" if config.NIX_PATH

        machine.communicate.tap do |comm|
          comm.execute(rebuild_cmd, sudo: true) do |type, data|
            if [:stderr, :stdout].include?(type)
              # Output the data with the proper color based on the stream.
              color = type == :stdout ? :green : :red

              options = {
                new_line: false,
                prefix: false,
              }
              options[:color] = color

              machine.env.ui.info(data, options) if config.verbose
            end
          end
        end
      end

      # rebuild the base vagrant.nix configuration
      def prepare!
        # build
        conf = <<CONF
{ config, pkgs, ... }:
{
  imports = [
    #{config.imports.join("\n  ")}
  ];
CONF
        # default NIX_PATH
        conf << <<CONF if config.NIX_PATH
  config.environment.shellInit = ''
    export NIX_PATH=#{config.NIX_PATH}:$NIX_PATH
  '';
CONF
        conf << '}'
        # output / build the config

        write_config("vagrant.nix", conf)
      end

      # Send file to machine.
      # Returns true if the uploaded file if different from any
      # preexisting file, false if the file is indentical
      def write_config(filename, conf)
        temp = Tempfile.new("vagrant")
        temp.binmode
        temp.write(CONFIG_HEADER + conf)
        temp.close
        changed = true
        machine.communicate.tap do |comm|
          source = "/tmp/#{filename}"
          target = "/etc/nixos/#{filename}"
          comm.upload(temp.path, source)
          if same?(source, target)
            changed = false
          else
            comm.sudo("mv #{source} #{target}")
          end
        end
        return changed
      end

      def same?(f1, f2)
        machine.communicate.test("cmp --silent #{f1} #{f2}")
      end
    end
  end
end
