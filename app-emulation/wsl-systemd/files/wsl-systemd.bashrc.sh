if [ -z "$WSL_INTEROP" ] && [ -r /run/WSL/systemd.env ]; then
  export $(grep -v '^#' /run/WSL/systemd.env | xargs -d '\n')
fi
