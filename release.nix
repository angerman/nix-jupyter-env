{
  nixpkgs ? import <nixpkgs> {}
}:

let
  inherit (nixpkgs) stdenv pkgs;

  # Trying to fix the cython package on darwin.
  pythonPackages = pkgs.python35Packages // {
    cython = pkgs.python35Packages.cython.override { NIX_CFLAGS_COMPILE = stdenv.lib.optionalString (stdenv.cc.isClang) "-I${pkgs.libcxx}/include/c++/v1"; };
  };

  # Define the ipythong_sql package
  # to provide the %sql magic command
  # to ipython.
  ipython_sql = pkgs.python35Packages.buildPythonPackage rec {
    name = "ipython-${version}";
    version = "0.38";

    # We need a patch for the setup.py, which tries to read the README.rst
    # and chokes due to some non-ascii encoding.
    patches = [ ./setup.py.patch ];
    propagatedBuildInputs = with pythonPackages; [ ipython_genutils sqlalchemy sqlparse prettytable ipython ];

    src = pkgs.fetchgit {
      url = "https://github.com/catherinedevlin/ipython-sql";
      rev = "refs/tags/v${version}";
      sha256 = "0myy3zgm90kxyyjq9krz8z8lx90l7j1pq267497l6p93d5ngcpb7";
    };

    meta = {
      homepage = "http://github.com/catherinedevlin/ipython-sql/";
      description = "%%sql magic for IPython, hopefully evolving into full SQL client";
    };
  };

  # It appears to be necessary to use python.buildEnv instead of pkgs.buildEnv in order to maintain the correct PYTHONPATH
  ipython-env = pythonPackages.python.buildEnv.override
                  {
                    extraLibs =
                      with pythonPackages;
                      [
                        notebook

                        # Python packages (comment/uncomment as needed)
                        ipywidgets
                        scipy
                        /* toolz */
                        numpy
                        /* matplotlib */
                        networkx
                        /* pandas */
                        /* seaborn */
                        ipython_sql
                        psycopg2
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
