_goScript()
{
  cur=${COMP_WORDS[COMP_CWORD]}
  COMPREPLY=( $( compgen -W "$(${1} --generate-bash-completion)" -- $cur ) )
}

if [[ -z ${GOPATH} ]]; then
   echo "GOPATH is not set. Skipping golang completions"
   return 0
fi

scriptDirs="${GOPATH}/bin"
supportedScripts=$(findExecutable ${scriptDirs} -maxdepth 1 2> /dev/null)

for s in ${supportedScripts}; do
  complete -o default -o filenames -F _goScript ${s} $(basename ${s}) ./$(basename ${s}) $(sed "s_${HOME}_~_" <<< ${s})
done
