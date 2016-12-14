{
  nixpkgs ? import <nixpkgs> {}
, pythonCompiler ? "python35"
}:

let
  inherit (nixpkgs) stdenv pkgs;

  pythonPackages = pkgs.${pythonCompiler + "Packages"};

  # It appears to be necessary to use python.buildEnv instead of pkgs.buildEnv in order to maintain the correct PYTHONPATH
  ipython-env = pythonPackages.python.buildEnv.override
                  {
                    extraLibs =
                      with pythonPackages;
                      [
                        notebook

                        # Python packages (comment/uncomment as needed)
                        ipywidgets
                        /* scipy */
                        /* toolz */
                        /* numpy */
                        /* matplotlib */
                        /* networkx */
                        /* pandas */
                        /* seaborn */
                      ];
                  };
in

  {
    inherit pythonPackages;
    jupyter-env = pkgs.buildEnv
      {
        name = "jupyter-env";
        paths = [ ipython-env ];
      };
  }
