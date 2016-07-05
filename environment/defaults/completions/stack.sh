if [[ -n $(which stack 2>/dev/null) ]]; then
  eval "$(stack --bash-completion-script stack)"
fi
