_branch()
{
  cur=${COMP_WORDS[COMP_CWORD]}
  COMPREPLY=( $( compgen -W "$(branch -lall | replace '*' ' ' | grep '^ ' | sort | uniq)" -- $cur ) )
}

complete -o default -o filenames -F _branch branch br
