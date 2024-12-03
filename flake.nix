{
  description = "A very basic flake";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs?ref=nixos-unstable";
  };

  outputs = { self, nixpkgs }: {
    packages.default = 
		let
			version = "5.2.4";
		in
		nixpkgs.stdenv.mkDerivation {
			name = "xlarig";
			src = nixpkgs.fetchFromGitHub {
				owner = "scala-network";
				repo = "XLArig";
				rev = "v${version}";
				hash = "sha256-kFjUAOs92xExCV/teehee=";
			};

			buildInputs = with nixpkgs; [
				cmake
				hwloc
				openssl
				libmicrohttpd
			];
		};
  };
}
