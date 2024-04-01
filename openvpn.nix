{ openvpn
, fetchpatch
}:

openvpn.overrideAttrs (oldAttrs: rec {
  patches = [
    (fetchpatch {
      url = "https://raw.githubusercontent.com/onjin/samlvpn-nix/master/openvpn-v2.5.x.diff";
      sha256 = "sha256-JHS91yGxs/C6verKNNtKg32AVvpepzhoXIwzKdvGu+8=";
    })
  ];
})
