_bashScript()
{
  cur=${COMP_WORDS[COMP_CWORD]}
  COMPREPLY=( $( compgen -W "$(${s} --listOptions)" -- $cur ) )
}

scriptDirs="${HOME}/CRON ${HOME}/bin"
grep -l -- --listOptions $(awk '{for(i=1;i<=NF;i++) print $i"/*"}' <<< ${scriptDirs})
supportedScripts=$(grep -l -- --listOptions $(awk '{for(i=1;i<=NF;i++) print $i"/*"}' <<< ${scriptDirs}))

echo supportedScripts=${supportedScripts}
for s in ${supportedScripts}; do
  echo $s $(basename ${s}) './'$(basename ${s}) $(sed "s_${HOME}_~_" <<< ${s})
  complete -o default -o filenames -F _bashScript ${s} $(basename ${s}) ./$(basename ${s}) $(sed "s_${HOME}_~_" <<< ${s})
done

