0.1.0 / 2015-10-18
==================

Big refactor / fork of the vagrant-nixos plugin.

Vagrant 1.6.4+ has capabilities to setup the hostname and networking by
writing to /etc/nixos/vagrant-hostname.nix and
/etc/nixos/vagrant-networking.nix respectively but doesn't run
`nixos-rebuild switch`.

This is a complementary plugin that just takes care of the provisioning. All
of the nice Nix+ruby DLS is from the original plugin.

