_goScript()
{
  cur=${COMP_WORDS[COMP_CWORD]}
  COMPREPLY=( $( compgen -W "$(${1} --generate-bash-completion)" -- $cur ) )
}

scriptDirs="${GOPATH}/bin"
supportedScripts=$(find ${scriptDirs} -perm +ugo+x -maxdepth 1 2> /dev/null)

for s in ${supportedScripts}; do
  complete -o default -o filenames -F _goScript ${s} $(basename ${s}) ./$(basename ${s}) $(sed "s_${HOME}_~_" <<< ${s})
done
