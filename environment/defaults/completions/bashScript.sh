_bashScript()
{
  cur=${COMP_WORDS[COMP_CWORD]}
  COMPREPLY=( $( compgen -W "$(${s} --listOptions)" -- $cur ) )
}

scriptDirs="${HOME}/CRON ${HOME}/bin"
supportedScripts=$(grep -l -- --listOptions $(awk '{for(i=1;i<=NF;i++) print $i"/*"}' <<< ${scriptDirs}))

echo supportedScripts=${supportedScripts}
for s in ${supportedScripts}; do
  complete -o default -o filenames -F _bashScript ${s} $(basename ${s}) ./$(basename ${s}) $(sed "s_${HOME}_~_" <<< ${s})
done

