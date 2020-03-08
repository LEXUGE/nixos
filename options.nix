# Options of configuration

{ ... }: {
  lib = {
    users = {
      ash = {
        enable = true;
        enableLaTeX = true; # enable full LaTeX or not
      };
    };
    devices = { x1c7 = { enable = true; }; };
  };
}
