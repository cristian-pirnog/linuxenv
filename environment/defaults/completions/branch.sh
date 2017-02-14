_branch()
{
  cur=${COMP_WORDS[COMP_CWORD]}
  COMPREPLY=( $( compgen -W "$(br --listOptions) $(br -lall | replace '*' ' ' | grep '^ ' | sort | uniq | sed 's/ //g')" -- $cur ) )
}

complete -o filenames -F _branch br
