# My nvim config https://github.com/MrEhbr/nvim-config
self: super: with super; {

    im-select = let
      pname = "im-select";
    in
    stdenv.mkDerivation {
      name = "${pname}";
      src =
        if stdenv.isAarch64 then
          (fetchurl {
            url = "https://raw.githubusercontent.com/daipeihust/im-select/master/macOS/out/apple/im-select";
            hash = "sha256-MbBlL421nvBpBs1qhjXcweYWKILoMAytSCqLW5f/8pA=";
          })
        else
          stdenv.isx86_64 (fetchurl {
            url = "https://raw.githubusercontent.com/daipeihust/im-select/master/macOS/out/intel/im-select";
            hash = "sha256-LeNx7tNev6XX644JF0nDdLOFZwnlWgOHlAmuWDFoePk=";
          });


      phases = [ "installPhase" ];

      installPhase = ''
        mkdir -p $out/bin
        install -D $src $out/bin/im-select
      '';

      meta = with lib; {
        description = "Switch your input method through terminal";
        homepage = "https://github.com/daipeihust/im-select";
        license = licenses.mit;
        platforms = platforms.darwin;
        mainProgram = "im-select";
      };
    };
}

