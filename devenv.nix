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
  scripts.run-dev-server.exec =
    "${pkgs.uv}/bin/uv run python manage.py runserver";

  scripts.run-prod-server.exec =
    "${pkgs.uv}/bin/uv run daphne devenv_deployment.asgi:application";


  tasks = {
    "deploy:make-migrations".exec = "${pkgs.uv}/bin/uv run python manage.py makemigrations";
    "deploy:migrate".exec = "${pkgs.uv}/bin/uv run python manage.py migrate";
    "deploy:load-base-db-data".exec = "${pkgs.uv}/bin/uv run python manage.py load_base_db_data";
    
    "dev:runserver".exec = "${pkgs.uv}/bin/uv run python manage.py runserver";
    "prod:runserver".exec = "${pkgs.uv}/bin/uv run daphne devenv_deployment.asgi:application";
  };

  processes = {
    silly-example.exec = "while true; do echo hello && sleep 1; done";
    ping.exec = "ping localhost";
    nvidia.exec = "nvidia-smi -l";
    django.exec = "run-prod-server";
  };

  enterShell = ''
    . .devenv/state/venv/bin/activate
    nvcc -V
    hello
  '';
}
