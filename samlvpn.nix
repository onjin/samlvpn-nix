{ lib, buildGoModule, fetchFromGitHub, makeWrapper, openvpn, xdg-utils
, configOverrides ? { }, samlvpnConfigPath ? null }:

buildGoModule rec {
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
    # If samlvpnConfigPath is null, use the default example config
    if [ -z ${samlvpnConfigPath} ]; then
      cp ${src}/config.example.yaml $out/samlvpn.yaml
    else
      cp ${samlvpnConfigPath} $out/samlvpn.yaml
    fi

    # Apply overrides from configOverrides
    ${lib.concatMapStringsSep "\n" (keyValue:
      let
        key = keyValue.key;
        value = keyValue.value;
      in "substituteInPlace $out/samlvpn.yaml --replace '${key}' '${value}'")
    (map (key: {
      key = key;
      value = configOverrides.${key};
    }) (builtins.attrNames configOverrides))}


    makeWrapper $out/bin/samlvpn $out/bin/saml-vpn \
      --run "cd $out" \
      --prefix PATH : "${lib.makeBinPath [ openvpn xdg-utils ]}" \
      --add-flags "-config $out/samlvpn.yaml"
  '';
}

