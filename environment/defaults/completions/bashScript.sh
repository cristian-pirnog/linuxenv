_bashScript()
{
  cur=${COMP_WORDS[COMP_CWORD]}
  COMPREPLY=( $( compgen -W "$(${s} --listOptions)" -- $cur ) )
}

scriptDirs="${HOME}/CRON ${HOME}/bin ${HOME}/.${USER}_config"
supportedScripts=$(grep -l -d skip -- --listOptions $(sed -E 's_ |$_/* _g' <<< ${scriptDirs}) 2> /dev/null)

for s in ${supportedScripts}; do
  complete -o default -o filenames -F _bashScript ${s} $(basename ${s}) ./$(basename ${s}) $(sed "s_${HOME}_~_" <<< ${s})
done

