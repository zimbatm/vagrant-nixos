require "vagrant-nixos/version"
require "vagrant-nixos/plugin"
require "vagrant-nixos/util"
require "vagrant-nixos/nix"

module VagrantPlugins
	module Nixos
		lib_path = Pathname.new(File.expand_path("../nixos", __FILE__))
		autoload :Action, lib_path.join("action")
		autoload :Errors, lib_path.join("errors")

	    # This returns the path to the source of this plugin.
	    def self.source_root
	    	@source_root ||= Pathname.new(File.expand_path("../../../", __FILE__))
	    end
	end
end
