if [ -z "$WSL_INTEROP" ] && [ -r /run/WSL/systemd.bashrc ]; then
  export $(grep -v '^#' /run/WSL/systemd.bashrc | xargs -d '\n')
fi
