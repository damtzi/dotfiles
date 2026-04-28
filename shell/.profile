export VOLTA_HOME="$HOME/.volta"
export PATH="$VOLTA_HOME/bin:$PATH"

[ -f "$HOME/.deno/env" ] && . "$HOME/.deno/env"
[ -f "$HOME/.cargo/env" ] && . "$HOME/.cargo/env"
