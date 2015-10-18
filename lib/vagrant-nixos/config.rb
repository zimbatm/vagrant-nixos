module VagrantPlugins
  module Nixos
    class Config < Vagrant.plugin("2", :config)
      attr_accessor :inline
      attr_accessor :path
      attr_accessor :expression
      attr_accessor :include
      attr_accessor :verbose
      attr_accessor :NIX_PATH

      def initialize
        @inline      = UNSET_VALUE
        @path        = UNSET_VALUE
        @expression  = UNSET_VALUE
        @include     = UNSET_VALUE
        @verbose     = UNSET_VALUE
        @NIX_PATH    = UNSET_VALUE
      end

      def finalize!
        @inline      = nil if @inline == UNSET_VALUE
        @path        = nil if @path == UNSET_VALUE
        @expression  = nil if @expression == UNSET_VALUE
        @include     = nil if @include == UNSET_VALUE
        @verbose     = nil if @verbose == UNSET_VALUE
        @NIX_PATH    = nil if @NIX_PATH == UNSET_VALUE
      end

      def expression=(v)
        @expression = v.to_nix
      end

      def validate(machine)
        errors = _detected_errors

        if (path && inline) or (path && expression) or (inline && expression)
          errors << "You can have one and only one of :path, :expression or :inline for nixos provisioner"
        elsif !path && !inline && !expression
          errors << "Missing :inline, :expression or :path for nixos provisioner"
        end

        if path && !File.exist?(path)
          errors << "Invalid path #{path}"
        end

        { "nixos provisioner" => errors }
      end
    end
  end
end
