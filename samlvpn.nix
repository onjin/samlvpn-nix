{ lib, buildGoModule, fetchFromGitHub, makeWrapper, openvpn, xdg-utils }:

buildGoModule rec {
  pname = "samlvpn";
  version = "d4b2b4b5588618491a64fa316c2103bfaaaa8095";

  src = fetchFromGitHub {
    owner = "donotnoot";
    repo = "samlvpn";
    rev = "${version}";
    sha256 = "sha256-ren8vRbfwDhHjT6dF/RBBL1TNlDXM9gVPJ47CAqQLFE";
  };

  vendorHash = "sha256-zvT9b1o+3ugfqifcRFpkbXWrZc/XBa/Q/1PR/g7P6W0=";

  nativeBuildInputs = [ makeWrapper ];

  postInstall = ''
     cp ${src}/config.example.yaml $out/samlvpn.yaml

     substituteInPlace $out/samlvpn.yaml \
       --replace '$HOME/.local/bin/openvpn-patched' "openvpn" \
       --replace /usr/bin/sudo "sudo"

    makeWrapper $out/bin/samlvpn $out/bin/saml-vpn \
      --run "cd $out" \
      --prefix PATH : "${lib.makeBinPath [ openvpn xdg-utils ]}"
  '';

}
