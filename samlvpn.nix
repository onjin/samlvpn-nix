{ lib, pkgs, buildGoModule, fetchFromGitHub, makeWrapper, openvpn, xdg-utils
, configOverrides ? { }, samlvpnConfigPath ? null }:
let
  defaultConfig = {
    openvpn-binary = "${openvpn}/bin/openvpn";
    openvpn-config-file = "$HOME/.config/samlvpn/samlvpn.ovpn";

    browser-command = [ "google-chrome-stable" "--new-tab" "%s" ];

    connection-lost-command =
      [ "notify-send" "SamlVPN" "Connection has been lost!" ];

    redirect-url = "https://vpn-only.com/";

    run-command = "true";
    auth-failed-retries = 10;
    temp-credentials-file-path = "$HOME/.samlvpn-creds";
    temp-credentials-file-permission = 600;
  };
  prettyYAML = attrs:
    builtins.concatStringsSep "\n" (lib.mapAttrsToList (k: v:
      if builtins.isList v then
        ''
          ${k}:
        '' + (builtins.concatStringsSep "\n"
          (map (item: "  - ${lib.strings.escapeNixString item}") v))
      else
        "${k}: ${toString v}") attrs);

  # Merge default config with user overrides (user wins)
  mergedConfig = lib.recursiveUpdate defaultConfig configOverrides;
  cfgText = prettyYAML mergedConfig;  # mergedConfig contains "$HOME" literally
  cfgFile = pkgs.writeText "samlvpn.yaml" cfgText;

in buildGoModule rec {
  pname = "samlvpn";
  version = "86f8ff490bfcab9fde7a39a25a22d0a4062f2d38";

  src = fetchFromGitHub {
    owner = "donotnoot";
    repo = "samlvpn";
    rev = "${version}";
    sha256 = "sha256-7RNY/WFRoBl8sVuwkGyVeEz/nn9pJliYhiAJQmJZRZs=";
  };

  vendorHash = "sha256-zvT9b1o+3ugfqifcRFpkbXWrZc/XBa/Q/1PR/g7P6W0=";

  nativeBuildInputs = [ makeWrapper ];

  postInstall = ''
    install -Dm444 ${cfgFile} $out/samlvpn.yaml
    makeWrapper $out/bin/samlvpn $out/bin/saml-vpn \
      --run "cd $out" \
      --prefix PATH : ${lib.makeBinPath [ openvpn xdg-utils ]} \
      --add-flags "-config $out/samlvpn.yaml"
  '';
}

