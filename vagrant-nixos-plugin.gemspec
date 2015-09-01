# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'vagrant-nixos/version'

Gem::Specification.new do |spec|
  spec.name          = "vagrant-nixos-plugin"
  spec.version       = VagrantPlugins::Nixos::VERSION
  spec.authors       = ["Chris Farmiloe"]
  spec.email         = ["chrisfarms@gmail.com"]
  spec.summary       = %q{Guest capabilities and nix provisioning for NixOS}
  spec.description   = %q{Add capabilities and basic nix configuration provisioning for NixOS guests in Vagrant}
  spec.homepage      = ""
  spec.license       = "MIT"

  spec.files         = `git ls-files -z`.split("\x0")
  spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.test_files    = spec.files.grep(%r{^(test|spec|features)/})
  spec.require_paths = ["lib"]

  spec.add_development_dependency "bundler", "~> 1.5"
  spec.add_development_dependency "rake"
  spec.add_dependency "netaddr"
end
