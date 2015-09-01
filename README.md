# NixOS Vagrant Plugin

This plugin makes working with [NixOS](http://nixos.org) guests in [Vagrant](http://www.vagrantup.com) a bit nicer:

* Allow network configurations
* Allow hostname setting
* Provide nix provisioning

## Install:

NOTE: this project is a fork of the `vagrant-nixos` gem. Both can't be
      installed at the same time.

```bash
$ vagrant plugin install vagrant-nixos-plugin
```

## Example Vagrantfile

```ruby
Vagrant.configure("2") do |config|

	# use a suitable NixOS base
	# http://github.com/oxdi/nixos
	config.vm.box = "nixos-14.02-x86_64"
	config.vm.box_url = "http://s3.amazonaws.com/oxdi/nixos-14.02-x86_64-virtualbox.box"
  	
  	# set hostname
  	config.vm.hostname = "nixy"
  
  	# Setup networking
	config.vm.network "private_network", :ip => "172.16.16.16"

	# Add the htop package
	config.vm.provision :nixos, :expression => {
		environment: {
			systemPackages: [ :htop ]
		}
	}

end
```

In the above `Vagrantfile` example we provision the box using the `:expression` method, which will perform a simple ruby -> nix conversion. `:expression` provisioning creates a nix module that executes with `pkgs` in scope. It is roughly equivilent to the below version that uses the `:inline` method.

```ruby
config.vm.provision :nixos, :inline => %{
	{config, pkgs, ...}: with pkgs; {
		environment.systemPackages = [ htop ];
	}
}, :NIX_PATH => "/custom/path/to/nixpkgs"
```

The above example also shows the optional setting of a custom `NIX_PATH` path.

You can also use an external nix configuration file:

```ruby
config.vm.provision :nixos, :path => “configuration.nix”
```

If you need provisioning to be included explicitly during rebuild use:

```ruby
config.vm.provision :nixos,
	:path => “configuration.nix”,
	:include => true
```

You can enable verbose provision output during rebuild process with:

```ruby
config.vm.provision :nixos,
	:path => “configuration.nix”,
	:verbose => true
```

If you need to use functions or access values using dot syntax you can use the `Nix` module:

```ruby
config.vm.provision :nixos, :expression => {
	services: {
		postgresql: {
			enable: true,
			package: Nix.pkgs.postgresql93,
			enableTCPIP: true,
			authentication: Nix.lib.mkForce(%{
				local all all              trust
				host  all all 127.0.0.1/32 trust
			}),
			initialScript: "/etc/nixos/postgres.sql"
		}
	}
}	
```


## How it works

In nixos we don't mess around with the files in `/etc` instead we write expressions for the system configuration starting in `/etc/nixos/configuration.nix`.

This plugin sets some ground rules for nixos boxes to keep this configuration clean and provisioning possible.

Box creators should ensure that their `configuration.nix` file imports an nix module `/etc/nixos/vagrant.nix` which will be overwritten by `vagrant-nixos-plugin` during `vagrant up` or `vagrant provision`.

See the configuration in our [NixOS packer template](http://github.com/oxdi/nixos) for an example.

## Issues

It's a bit slow on the initial boot/provision at the moment as it must run nixos-rebuild several times. This is far from ideal I'm sure I'll find a better place to hook in the rebuild step soon.

