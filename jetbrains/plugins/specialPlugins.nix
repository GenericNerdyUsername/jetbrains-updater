{ delve, autoPatchelfHook, stdenv, gcc-unwrapped }:
# This is a list of plugins that need special treatment. For example, the go plugin (id is 9568) comes with delve, a
# debugger, but that needs various linking fixes. The changes here replace it with the system one.
{
  "631" = { # Python
    nativeBuildInputs = [ autoPatchelfHook ];
    buildInputs = [ gcc-unwrapped ];
  };
  "7322" = {  # Python community edition
    nativeBuildInputs = [ autoPatchelfHook ];
    buildInputs = [ gcc-unwrapped ];
  };
  "7495" = { # .ignore
    buildPhase = ''
      echo "Due to the unpacked directory starting with a `.`, this plugin won't work until #191355 is merged."
      exit 1
      '';
  };
  "8182" = { # Rust
    nativeBuildInputs = [ autoPatchelfHook ];
    commands = "chmod +x -R bin";
  };
  "9568" = {  # Go
    buildInputs = [ delve ];
    commands = let
      arch = (if stdenv.isLinux then "linux" else "mac") + (if stdenv.isAarch64 then "arm" else "");
    in "ln -sf ${delve}/bin/dlv lib/dlv/${arch}/dlv";
  };
}