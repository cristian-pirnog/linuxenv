_bashScript()
{
  cur=${COMP_WORDS[COMP_CWORD]}
  COMPREPLY=( $( compgen -W "$(${1} --listOptions)" -- $cur ) )
}

scriptDirs=("${HOME}/CRON" "${HOME}/bin" "${HOME}/.${USER}_config")
for d in ${scriptDirs[@]}; do
    files=$(findExecutable "${d}" \( -type f -o -type l \) )
    if [[ -n ${files} ]]; then
	supportedScripts=${supportedScripts}' '$(grep -l -d skip -- --listOptions ${files} 2> /dev/null)
    fi
done


for s in ${supportedScripts}; do
  complete -o default -o filenames -F _bashScript ${s} $(basename ${s}) ./$(basename ${s}) $(sed "s_${HOME}_~_" <<< ${s})
done


