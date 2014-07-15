_optimizer()
{
  cur=${COMP_WORDS[COMP_CWORD]}
  #COMPREPLY=( $( compgen -W "$(./rocardian.optimizer listCommands})" -- $cur ) )
  COMPREPLY=( $( compgen -W "correlationAnalysis printData DataQuality expiryAnalysis LiquidityAnalysis optimize OrderLogParser simulate staticInfo translate" -- $cur ) )
}

complete -o default -o filenames -F _optimizer ./rocardian.optimizer.exe
complete -o default -o filenames -F _optimizer ./ronin.optimizer.exe

complete -o default -o filenames -F _optimizer ./run.sh
