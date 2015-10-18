module VagrantPlugins
  module Nixos
    class Guest < Vagrant.plugin("2", :guest)
      attr_accessor :nix_imports

      def detect?(machine)
        machine.communicate.test("test -d /etc/nixos")
      end
    end
  end
end
