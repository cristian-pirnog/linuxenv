bin 
===
This directories contains scripts that I wrote.


CRON
====
This directories contains scripts for various cron jobs. It also contains a cron.tab file which can be used
for setting the cron jobs.


bookmarks.html
==============
This is the bookmarks file for Mozilla web-browser. It whould be placed in directory ~/.mozilla/default/randName.


dot_aliases
===========
requires: dot_dircolors

dot_bashrc
==========
requires: dot_aliases


dot_dabbrev
===========
Provides the 'dynamic abbreviation' package for xemacs.


dot_dircolors
=============
This file contains the customized colors for the 'ls' command.


dot_vim
=======
This directory contains configuration files for the VIM editor.


dot_vimrc
=========
Provides configuration for the VIM editor.


dot_xemacs
==========
requires: dot_dabbrev


firefox
=======
Directory with goodies for Mozilla Firefox. See the README file inside it.

install_crpi
============
Script for automatic installation of the 'crpi' customized environment.


metacity
========
This directory contains some key-bindings for executing various commands. In order to make it
work in Gnome, it should be copied in the directory: ~/.gconf/apps/.


README.txt
==========
This file. 


subversion_config
=================
Provides configuration for SVN (subversion). It should be placed in directory ~/.subversion.


XTerm
=====
Provides configuration for the xterm program.


XTerm-color
===========
requires: XTerm
Specifies the colors that an xterm uses (e.g. background, file names, dir names, etc.). This file has to be placed in directory /usr/X11R6/lib/X11/app-defaults (same as XTerm).


fstab
=====
Provides the mounts for the precision650 machine. Should be placed in directory /etc.


.vimrc
======
requires: dot_vim
Provides configuration for the 'vim' editor (e.g. colors, etc.). The color
scheme is configured in a file in the directory dot_vim.


xorg.conf
=========
Provides configuration for Xinerama with 2 displays, using the NVidia graphic
card (for the precision650 machine). The file should be placed in directory /etc/X11.
