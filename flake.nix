{
  description = "SAML VPN patched client";

  inputs.flake-utils.url = "github:numtide/flake-utils";

  outputs = { self, nixpkgs, flake-utils }:
    flake-utils.lib.eachDefaultSystem (system:
      let pkgs = nixpkgs.legacyPackages.${system};
      in rec {
        packages = flake-utils.lib.flattenTree {
          samlvpn = pkgs.callPackage ./samlvpn.nix {
            openvpn = pkgs.callPackage ./openvpn.nix { };
            configOverrides = {
              "$HOME/.local/bin/openvpn-patched" =
                "${pkgs.openvpn}/bin/openvpn";
              "$HOME/.config/openvpn-corporate.ovpn" =
                "/etc/samlvpn/config.ovpn";
              "run-command: false" = "run-command: true";
              "chromium" = "google-chrome-stable";
            };
            # samlvpnConfigPath = "/path/to/custom/samlvpn.yaml"; # Optional
            samlvpnConfigPath = ""; # Optional
          };
          # you can override the default samlvpn package by using the following in your overlay:
          # {
          #   modifications = final: prev: {
          #     samlvpn = prev.samlvpn.override {
          #       configOverrides = {
          #         'run-command: false' = 'run-command: true';
          #         '$HOME/.config/openvpn-corporate.ovpn' = '/my/custom/path.ovpn';
          #       };
          #     };
          #   };
          # }
        };
        defaultPackage = packages.samlvpn;
        # Add devShell for the system
        devShell = pkgs.mkShell {
          name = "samlvpn-devshell";
          buildInputs = [
            pkgs.go # Go compiler
            pkgs.git # Git for fetching dependencies
            pkgs.makeWrapper # Wrapper scripts
            pkgs.xdg-utils # XDG utilities (for runtime)
            pkgs.openvpn # OpenVPN for testing
          ];

          # Set environment variables for easier testing
          shellHook = ''
            if [ -d "${self.packages.${system}.samlvpn or ""}" ]; then
              export PATH=${self.packages.${system}.samlvpn}/bin:$PATH
              echo "DevShell for samlvpn is ready. Use 'samlvpn' or 'saml-vpn' for testing."
            else
              echo "Warning: samlvpn is not available in the PATH. Ensure it is built before testing."
            fi
          '';
        };
      });
}
