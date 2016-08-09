_branch()
{
  cur=${COMP_WORDS[COMP_CWORD]}
  COMPREPLY=( $( compgen -W "$(br --listOptions) $(br -lall | replace '*' ' ' | grep '^ ' | sort | uniq)" -- $cur ) )
}

complete -o default -o filenames -F _branch br
