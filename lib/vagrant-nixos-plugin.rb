require "vagrant-nixos/version"
require "vagrant-nixos/plugin"
require "vagrant-nixos/util"
require "vagrant-nixos/nix"

module VagrantPlugins
  module Nixos
    SOURCE_ROOT = Pathname.new('../../..').expand_path(__FILE__)
    lib_path = SOURCE_ROOT + 'lib/vagrant-nixos'
    autoload :Action, lib_path.join("action")
    autoload :Errors, lib_path.join("errors")

      # This returns the path to the source of this plugin.
      def self.source_root
        SOURCE_ROOT
      end
  end
end
