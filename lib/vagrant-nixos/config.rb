module VagrantPlugins
  module Nixos
    class Config < Vagrant.plugin("2", :config)
      # Some inline nix configuration data
      # @return [String, nil]
      attr_accessor :inline

      # The path to some nix configuration file
      # @return [String, nil]
      attr_accessor :path

      # Some inline ruby DSL that generates nix configuration data
      # @return [Hash, nil]
      attr_accessor :expression

      # Include /etc/nixos/vagrant.nix in the build
      # @return [true, false]
      attr_accessor :include

      # Show debug information during the build
      # @return [true, false]
      attr_accessor :verbose

      # Override the default NIX_PATH
      # @return [String, nil]
      attr_accessor :NIX_PATH

      # Configure which files to import in the vagrant.nix file
      # @return [Array<String>]
      attr_accessor :imports

      def initialize
        @inline      = UNSET_VALUE
        @path        = UNSET_VALUE
        @expression  = UNSET_VALUE
        @include     = UNSET_VALUE
        @verbose     = UNSET_VALUE
        @NIX_PATH    = UNSET_VALUE
        @imports     = [
          "./vagrant-network.nix",
          "./vagrant-hostname.nix",
          "./vagrant-provision.nix",
        ]
      end

      def finalize!
        @inline      = nil    if @inline      == UNSET_VALUE
        @path        = nil    if @path        == UNSET_VALUE
        @expression  = nil    if @expression  == UNSET_VALUE
        @include     = false  if @include     == UNSET_VALUE
        @verbose     = false  if @verbose     == UNSET_VALUE
        @NIX_PATH    = nil    if @NIX_PATH    == UNSET_VALUE
      end

      def expression=(v)
        @expression = v.to_nix
      end

      def validate(machine)
        errors = _detected_errors

        if (path && inline) or (path && expression) or (inline && expression)
          errors << "You can have one and only one of :path, :expression or :inline for nixos provisioner"
        end

        if path && !File.exist?(path)
          errors << "Invalid path #{path}"
        end

        unless imports.is_a?(Array)
          errors << "Expected imports to be an array of paths"
        end

        { "nixos provisioner" => errors }
      end
    end
  end
end
