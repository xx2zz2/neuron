let 
  ghc = (import ./project.nix {}).ghc;
  haskellNeuron = ghc.neuron.overrideDerivation (drv: {
    # Avoid transitive runtime dependency on the whole GHC distribution due to
    # Cabal's `Path_*` module thingy. For details, see:
    # https://github.com/NixOS/nixpkgs/blob/46405e7952c4b41ca0ba9c670fe9a84e8a5b3554/pkgs/development/tools/pandoc/default.nix#L13-L28
    #
    # In order to keep this list up to date, use nix-store and why-depends as
    # explained here: https://www.srid.ca/04b88e01.html
    disallowedReferences = [ 
      ghc.pandoc 
      ghc.pandoc-types 
      ghc.shake ghc.warp 
      ghc.HTTP 
      ghc.js-jquery 
      ghc.js-dgtable 
      ghc.js-flot 
    ];
    postInstall = ''
      remove-references-to -t ${ghc.pandoc} $out/bin/neuron
      remove-references-to -t ${ghc.pandoc-types} $out/bin/neuron
      remove-references-to -t ${ghc.shake} $out/bin/neuron
      remove-references-to -t ${ghc.warp} $out/bin/neuron
      remove-references-to -t ${ghc.HTTP} $out/bin/neuron
      remove-references-to -t ${ghc.js-jquery} $out/bin/neuron
      remove-references-to -t ${ghc.js-dgtable} $out/bin/neuron
      remove-references-to -t ${ghc.js-flot} $out/bin/neuron
      remove-references-to -t /nix/store/6cl2k4q0kllb8727vpwni0dxdycqg38m-js-jquery-3.3.1-data $out/bin/neuron
      remove-references-to -t /nix/store/bicv5nnibqg0qsqyjvb3nw01447yms0j-shake-0.18.5-data $out/bin/neuron
      remove-references-to -t /nix/store/qdh8gnxxw5y1fiklg7c3mdwpf3qablq5-js-flot-0.8.3-data $out/bin/neuron
      remove-references-to -t /nix/store/vjf3s5d2f9zv2ip870k4jfb2lg9r5v93-pandoc-2.9.2.1-data $out/bin/neuron
      remove-references-to -t /nix/store/z38lbhs05zb0gryqpggr1mncm7r56a3a-js-dgtable-0.5.2-data $out/bin/neuron
    '';
  });
  pkgs = import <nixpkgs> {};
  neuronBin = pkgs.stdenvNoCC.mkDerivation {
    name = "neuron";
    buildInputs = [ haskellNeuron pkgs.removeReferencesTo ];
    buildCommand = ''
      mkdir -p $out/bin
      cp ${haskellNeuron}/bin/neuron $out/bin/neuron
      runHook postInstall
      '';
    allowSubstitutes = true;
    postInstall = ''
      remove-references-to -t ${haskellNeuron} $out/bin/neuron
      '';
    };
in 
  neuronBin
