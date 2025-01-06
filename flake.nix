{
  description = "XLA miner";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs?ref=nixos-unstable";
  };

  outputs = { self, nixpkgs }: 
    let
      supportedSystems = [ "x86_64-linux" "aarch64-linux" "x86_64-darwin" "aarch64-darwin" ];
      forAllSystems = nixpkgs.lib.genAttrs supportedSystems;
    in
    {
      packages = forAllSystems (system:
        let
          pkgs = nixpkgs.legacyPackages.${system};
          version = "5.2.4";
        in
        {
          default = pkgs.stdenv.mkDerivation {
            pname = "xlarig";
            inherit version;
            
            src = pkgs.fetchFromGitHub {
              owner = "scala-network";
              repo = "XLArig";
              rev = "v${version}";
              hash = "sha256-fMCuo0rp+Lve0gXkJEIfB0//g2VdlVOqieDvOBHFBYU=";
            };

            buildInputs = with pkgs; [
              cmake
              hwloc
              openssl
              libmicrohttpd
              libuv
            ];
						
						hardeningDisable = [ "fortify" ];

            nativeBuildInputs = with pkgs; [
              cmake
							pkg-config
            ];

            configurePhase = if pkgs.stdenv.isDarwin then ''
              cmake -B build \
								-DOPENSSL_ROOT_DIR=${pkgs.openssl.dev} \
								-DOPENSSL_CRYPTO_LIBRARY=${pkgs.openssl.out}/lib/libcrypto.dylib \
								-DOPENSSL_SSL_LIBRARY=${pkgs.openssl.out}/lib/libssl.dylib \
								-DOPENSSL_INCLUDE_DIR=${pkgs.openssl.dev}/include
            '' else ''
							cmake -B build
						'';

            buildPhase = ''
              cmake --build build --parallel $NIX_BUILD_CORES
            '';

            installPhase = ''
              install -D build/xlarig $out/bin/xlarig
            '';
          };
        });
    };
}
