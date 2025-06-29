{
  description = "nopswd - Stateless Password Manager";

  inputs.nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";

  outputs = { self, nixpkgs }: {
    packages.x86_64-linux.default =
      nixpkgs.legacyPackages.x86_64-linux.buildGoModule {
        name = "nopswd";
        src = self;
        vendorHash = "sha256-Bec2XF0vdVZp+ngQG+rF4DAEgPo+SO5ee3jH3lJ2m4s=";
        buildPhase = "go build -ldflags='-s -w' -o nopswd main.go";
        installPhase = ''
          mkdir -p $out/bin
          cp nopswd $out/bin/
        '';
      };
  };
}

