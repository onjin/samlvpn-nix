{ openvpn
, fetchpatch
}:

openvpn.overrideAttrs (oldAttrs: rec {
  patches = [
    (fetchpatch {
      url = "https://raw.githubusercontent.com/onjin/samlvpn-nix/master/openvpn-v2.5.x.diff";
      sha256 = "sha256-pbgmt5o/0k4lZ/mZobl0lgg39kxEASpk5hf6ndopayY=";
    })
  ];
})
