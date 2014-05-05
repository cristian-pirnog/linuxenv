_optimizer()
{
  cur=${COMP_WORDS[COMP_CWORD]}
  case "${cur}" in
    o*) use="optimize" ;;
    s*) use="simulate" ;;
  esac
  COMPREPLY=( $( compgen -W "$(./rocardian.optimizer listCommands})" -- $cur ) )
}

complete -o default -o filenames -F _optimizer ./rocardian.optimizer
