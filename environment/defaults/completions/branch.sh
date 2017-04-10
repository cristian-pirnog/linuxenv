_branch()
{
    cur=${COMP_WORDS[COMP_CWORD]}
    # The list of branches comes on the next line, otherwise the last option and the
    # first branch will be considered as one unit
  COMPREPLY=( $( compgen -W "$(br --listOptions)
$(br -lall | replace '*' ' ' | grep '^ ' | sort | uniq | sed 's/ //g')" -- $cur ) )
}

complete -o filenames -F _branch br
