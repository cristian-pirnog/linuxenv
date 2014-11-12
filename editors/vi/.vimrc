" VIM settings used for development

set nocompatible	    " Use Vim defaults (much better!)
set bs=2	            " allow backspacing over everything in insert mode
set ai		            " always set autoindenting on	
set viminfo='20,\"50	" read/write a .viminfo file, don't store more
			            " than 50 lines of registers
set history=150		    " keep 150 lines of command line history
set ruler		        " show the cursor position all the time

set ts=4	            "set tabstop = 4
set sw=4	            "set tabstop = 4 >> << commands
set expandtab
set vb t_vb=            " set visual bell off

set ignorecase
set autoindent
set smartindent

" colorscheme cristian_color_scheme
" colorscheme blue
" some abbreviations
" ab //- //--------------------------------------------------------------------
" ab catch catch(Exception anException)<CR>{<CR>new Fault( .class, this).log(anException);<CR>}<CR>
" ab try try<CR>{<CR>}<CR>catch (Exception anException)<CR>{<CR>new Fault( .class,this).log(anException);<CR>}<CR><UP><UP><UP><UP>
" ab acc public void<CR>accept(Visitor aVisitor)<CR>{<CR>if (theTrace.ACTIVE) theTrace.println("accept(" +<CR>"aVisitor = " + aVisitor + ")");<CR><CR>if (aVisitor instanceof Visitor)<CR>{<CR>((Visitor)aVisitor).visit (this);<CR>}<CR>else<CR>{<CR>aVisitor.deny(this);<CR>}<CR>}<CR>
" ab memc //--------------------------------------------------------------------<CR>// members<CR>//--------------------------------------------------------------------<CR>private final static Trace theTrace =<CR><TAB>new Trace( .class.getName());<LEFT><LEFT><LEFT><LEFT><LEFT><LEFT><LEFT><LEFT><LEFT><LEFT><LEFT><LEFT><LEFT><LEFT><LEFT><LEFT><LEFT><LEFT><LEFT>
" ab pubc //--------------------------------------------------------------------<CR>// public<CR>//--------------------------------------------------------------------<CR>
" ab pric //--------------------------------------------------------------------<CR>// private<CR>//--------------------------------------------------------------------<CR>
" ab proc //--------------------------------------------------------------------<CR>// protected<CR>//--------------------------------------------------------------------<CR>
"ab st String
"ab St String
"ab sta static
"ab pr private
"ab pro protected
"ab pu public
"ab vo void
"ab bo boolean
"ab fin final
"ab re return
"ab logg Logger.instance().log("");
"ab asrt if (Assert.ON) Assert.on(  != null, " ");
"ab asrtf if (Assert.ON) Assert.on(false, "Invalid function called");
"ab reg Registry.instance().get( ).stringValue();
"ab sop  System.out.println("");<LEFT><LEFT><LEFT>

ab svnsplit MatlabInfo:split; branch:XXX; in_revision:XXX; base:XXX
ab svnmerge MatlabInfo:merge; origin:XXX; target:XXX; range:XXX:YYY;

"ab tr <ESC>ma?(<CR>:.,/{/!/home/developer/bin/TraceFilter.pl<ESC>`a<ESC>i
"ab tra <ESC>ma?(<CR>:.,/{/!/home/developer/bin/TraceAssertFilter.pl<ESC>`a<ESC>i
"ab cpc <ESC>ma?(<CR>:.,/{/!/home/developer/bin/CopyConstructor.pl<ESC>`a<ESC>i

" rew and save
map <F2> <ESC>:rew<CR>

" Switch on/off search highlighting
map <F4> : set nohls<CR>
imap <F4> <C-O>:set nohls<CR>
map <F5> : set hls<CR>
imap <F5> <C-O>:set hls<CR>

" set the tab size to 2/4
map <F6>  : tabp <CR>
map <F7>  : tabn <CR>

" map keyboard to toggle paste mode
map <F9> :set paste<CR> 
map <F10> :set nopaste<CR>

" show status line
set laststatus=2
set statusline=%<%f\ [%1*%M%*%n%R%H]\ %=%-20(%5l,%2c%3V%)Lines\(%02L\)


hi Search  ctermfg=1 ctermbg=3
hi IncSearch  ctermfg=1 ctermbg=3
hi StatusLine  term=underline ctermfg=4 ctermbg=8
hi ModeMsg  term=bold ctermfg=4 ctermbg=8

set cpt=.,w,b,u,t,i,k/usr/dict/words " set completition for all possible words

" Only do this part when compiled with support for autocommands
if has("autocmd")
  " In text files, always limit the width of text to 78 characters
  autocmd BufRead *.txt set tw=78
  " When editing a file, always jump to the last cursor position
  autocmd BufReadPost * if line("'\"") | exe "'\"" | endif
endif

" Don't use Ex mode, use Q for formatting
map Q gq

" Switch syntax highlighting on, when the terminal has colors
" Also switch on highlighting the last used search pattern.
if &t_Co > 2 || has("gui_running")
  syntax on
  set hlsearch
endif

if has("autocmd")
 augroup cprog
  " Remove all cprog autocommands
  au!

  " When starting to edit a file:
  "   For C and C++ files set formatting of comments and set C-indenting on.
  "   For other files switch it off.
  "   Don't change the order, it's important that the line with * comes first.
  autocmd FileType *      set formatoptions=tcql nocindent comments&
  autocmd FileType c,cpp  set formatoptions=croql cindent comments=sr:/*,mb:*,el:*/,://
 augroup END

 augroup gzip
  " Remove all gzip autocommands
  au!

  " Enable editing of gzipped files
  "	  read:	set binary mode before reading the file
  "		uncompress text in buffer after reading
  "	 write:	compress file after writing
  "	append:	uncompress file, append, compress file
  autocmd BufReadPre,FileReadPre	*.gz set bin
  autocmd BufReadPost,FileReadPost	*.gz let ch_save = &ch|set ch=2
  autocmd BufReadPost,FileReadPost	*.gz '[,']!gunzip
  autocmd BufReadPost,FileReadPost	*.gz set nobin
  autocmd BufReadPost,FileReadPost	*.gz let &ch = ch_save|unlet ch_save
  autocmd BufReadPost,FileReadPost	*.gz execute ":doautocmd BufReadPost " . expand("%:r")

  autocmd BufWritePost,FileWritePost	*.gz !mv <afile> <afile>:r
  autocmd BufWritePost,FileWritePost	*.gz !gzip <afile>:r

  autocmd FileAppendPre			*.gz !gunzip <afile>
  autocmd FileAppendPre			*.gz !mv <afile>:r <afile>
  autocmd FileAppendPost		*.gz !mv <afile> <afile>:r
  autocmd FileAppendPost		*.gz !gzip <afile>:r
 augroup END
endif
if &term=="xterm"
     set t_Co=4
     set t_Sb=^[4%dm
     set t_Sf=^[3%dm
endif

" set search highlighting
set is
set nohls
