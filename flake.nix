{
  inputs.nixpkgs.url = "github:NixOS/nixpkgs/nixos-24.11";
  outputs = {nixpkgs, self}: {
    packages = nixpkgs.lib.genAttrs nixpkgs.lib.systems.flakeExposed (system:
      let pkgs = nixpkgs.legacyPackages."${system}";
          emacs = pkgs.emacs-pgtk;
          sbclBin = "${pkgs.sbcl}/bin/sbcl";

          lib = nixpkgs.lib;
          emacsWithPackages = (pkgs.emacsPackagesFor emacs).emacsWithPackages (epkgs: with epkgs; [
            company
            doom-themes
            marginalia
            slime
            slime-company
            smartparens
            vertico
          ]);
          patchStep = includeExtra: ''
            set -e

            emacsCompile() {
              $emacs/bin/emacs --batch -f batch-byte-compile "$@"
              
              ${lib.optionalString emacs.withNativeCompilation ''
                $emacs/bin/emacs --batch \
                  --eval "(add-to-list 'native-comp-eln-load-path \"$out/share/emacs/native-lisp/\")" \
                  -f batch-native-compile "$@"
              ''}
            }

            substitute ${./lmao-site-start.el} $out/share/emacs/site-lisp/lmao-site-start.el --subst-var-by sbcl "${sbclBin}"
            ${lib.optionalString includeExtra ''
              echo '(cua-mode 1)' >> $out/share/emacs/site-lisp/lmao-site-start.el
            ''}

            echo "(load \"$out/share/emacs/site-lisp/lmao-site-start\")" >> "$out/share/emacs/site-lisp/site-start.el"
            emacsCompile "$out/share/emacs/site-lisp/site-start.el" "$out/share/emacs/site-lisp/lmao-site-start.el"
          '';
          phaseToPatch = drvAttrs: lib.lists.findFirst (name: builtins.hasAttr name drvAttrs) null ["buildCommand" "installPhase" "buildPhase"];
          patch = drvAttrs: extras: {
            "${phaseToPatch drvAttrs}" = ''
              ${drvAttrs."${phaseToPatch drvAttrs}"}
              ${extras}
            '';
          };
      in rec {
        minimal = emacsWithPackages;
        stock = emacsWithPackages.overrideAttrs (final: prev: {
          deps = (prev.deps.overrideAttrs (depFinal: depPrev: depPrev // (patch depPrev (patchStep false))));
        });
        newcomer = emacsWithPackages.overrideAttrs (final: prev: {
          deps = (prev.deps.overrideAttrs (depFinal: depPrev: depPrev // (patch depPrev (patchStep true))));
        });
      });
  };
}
