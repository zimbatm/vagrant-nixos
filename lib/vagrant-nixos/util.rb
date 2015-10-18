module VagrantPlugins
  module Nixos
    ##############################################
    # Not sure if this is legit. But We'll use this module
    # to store the state of the nix configuration and handle
    # sending it to the machine.
    #############################################

    @@imports = {}

    # Send file to machine and report if it changed
    # See _write_config
    def self.write_config(machine, filename, conf)
      include_config(machine, filename)
      _write_config(machine, filename, conf)
    end

    # mark a file that should be imported to the main config
    def self.include_config(machine, filename)
      if @@imports[machine.id].nil?
        @@imports[machine.id] = {}
      end
      @@imports[machine.id][filename] = true
    end

    def imports
    end

    # rebuild the base vagrant.nix configuration
    def self.prepare(machine, config)
      # build
      conf = "{ config, pkgs, ... }:\n{"
      # Add a mock provision file if it is missing as during boot the
      # provisioning file may not be deployed yet.
      if !machine.communicate.test("test -f /etc/nixos/vagrant-provision.nix")
        _write_config(machine, "vagrant-provision.nix", "{ config, pkgs, ... }: {}")
      end
      # imports
      include_config(machine, 'vagrant-provision.nix')
      conf_paths =
        @@imports[machine.id].keys.inject([]) do |paths, filename|
          paths << "./#{filename}"
        end
      # construct the nix module
      conf << %{
        imports = [
          #{conf_paths.join("\n\t\t")}
        ];
      }
      # default NIX_PATH
      if config.NIX_PATH
        conf << %{
          config.environment.shellInit = ''
            export NIX_PATH=#{config.NIX_PATH}:$NIX_PATH
          '';
        }
      end
      conf << "}"
      # output / build the config
      _write_config(machine, "vagrant.nix", conf)
    end

    # just do nixos-rebuild
    def self.rebuild!(machine, config)
      self.prepare(machine, config)
      # Add a tmp vagreant.nix file if it is missing
      if !machine.communicate.test("grep 'provision' </etc/nixos/vagrant.nix")
        _write_config(machine, "vagrant.nix", %{{ config, pkgs, ... }: { imports = [ ./vagrant-provision.nix ];}})
      end
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

    def self.same?(machine, f1, f2)
      machine.communicate.test("cmp --silent #{f1} #{f2}")
    end

    protected

    # Send file to machine.
    # Returns true if the uploaded file if different from any 
    # preexisting file, false if the file is indentical
    def self._write_config(machine, filename, conf)
      temp = Tempfile.new("vagrant")
      temp.binmode
      temp.write(conf)
      temp.close
      changed = true
      machine.communicate.tap do |comm|
        source = "/tmp/#{filename}"
        target = "/etc/nixos/#{filename}"
        comm.upload(temp.path, source)
        if same?(machine, source, target)
          changed = false
        else
          comm.sudo("mv #{source} #{target}")
        end
      end
      return changed
    end
  end
end
