{
  description = "nopswd - Stateless Password Manager";

  inputs.nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";

  outputs = { self, nixpkgs }: {
    packages.x86_64-linux.default = nixpkgs.legacyPackages.x86_64-linux.stdenv.mkDerivation {
      name = "nopswd";
      src = self;
      buildInputs = [ nixpkgs.legacyPackages.x86_64-linux.odin ];
      buildPhase = "odin build . -out:nopswd -o:size -no-bounds-check";
      installPhase = ''
        strip nopswd
        mkdir -p $out/bin
        cp nopswd $out/bin/
      '';
    };
  };
}
