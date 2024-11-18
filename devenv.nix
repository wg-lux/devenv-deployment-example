{ pkgs, lib, config, inputs, ... }:
let
  buildInputs = with pkgs; [
    python312Full
    # cudaPackages.cuda_cudart
    # cudaPackages.cudnn
    stdenv.cc.cc
  ];
in 
{
  packages = with pkgs; [
    cudaPackages.cuda_nvcc
  ];

  env = {
    LD_LIBRARY_PATH = "${
      with pkgs;
      lib.makeLibraryPath buildInputs
    }:/run/opengl-driver/lib:/run/opengl-driver-32/lib";
  };

  languages.python = {
    enable = true;
    uv = {
      enable = true;
      sync.enable = true;
    };
  };

  scripts.hello.exec = "${pkgs.uv}/bin/uv run python hello.py";

  processes = {
    silly-example.exec = "while true; do echo hello && sleep 1; done";
    ping.exec = "ping localhost";
    nvidia.exec = "nvidia-smi -l";
  };

  enterShell = ''
    . .devenv/state/venv/bin/activate
    nvcc -V
    hello
  '';
}
