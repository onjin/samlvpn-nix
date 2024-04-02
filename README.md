# samlvpn

The Nix Flake for samlvpn with patched openvpn 2.5 to use openvpn with SAML authentication.

- https://github.com/donotnoot/samlvpn

You will get two binaries:
 - `samlvpn` - binary built from repository
 - `saml-vpn` - wrapper with `PATH` changed to use `openvpn-2.5` with generated `samlvpn.yaml`; by default it's looking for VPN profile at 
 `$HOME/.config/samlvpn/samlvpn.ovpn` and starts `openvpn` automatically.
