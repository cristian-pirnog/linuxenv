# .bash_profile

if [ -f ~/.bashrc ]; then
        . ~/.bashrc
fi

# User specific environment and startup programs

PATH=$HOME/bin:/home/env/bin:$PATH

export PATH
unset USERNAME

