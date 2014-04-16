" .vimrc
" Author: Elon Flegenheimer - http://www.elonflegenheimer.com
"
" Credit: http://learnvimscriptthehardway.stevelosh.com/
" Credit: https://bitbucket.org/sjl/dotfiles/src/6908dae7c07b16bad71796a38613393973ebe7cd/vim/vimrc?at=default
" Credit: https://github.com/tpope/tpope/blob/master/.vimrc
" Credit: http://vim.wikia.com/wiki/Vim_Tips_Wiki
" Credit: http://www.vim.org/scripts/script.php?script_id=2226

" important {{{

call pathogen#infect()           " install pathogen under ~/.vim/autoload
syntax on
filetype plugin indent on
set nocompatible

" }}}

" basics {{{

let mapleader=","
let maplocalleader = "\\"

set hidden  		" hide buffers instead of closing them
set modelines=0 	" security risk
set pastetoggle=<F2>
set virtualedit=block   " allow virtual editing in visual block mode

set laststatus=2 	" always show status line
set listchars=tab:▸\ ,eol:¬,extends:❯,precedes:❮
set number          " line numbers; alt: relativenumber - make line numbers relative to current
set scrolloff=1 	" screen lines preserved when scrolling above/below
set showcmd
set showmatch       " blink matching bracket
set spellfile=~/.vim/custom-dictionary.utf-8.add
set statusline=[%n]\ %<%.99f\ %h%w%m%r%{exists('*CapsLockStatusline')?CapsLockStatusline():''}%y%{exists('*rails#statusline')?rails#statusline():''}%{exists('*fugitive#statusline')?fugitive#statusline():''}%#ErrorMsg#%{exists('*SyntasticStatuslineFlag')?SyntasticStatuslineFlag():''}%*%=%-16(\ %l,%c-%v\ %)%P
set ttyfast
set visualbell

" TODO rebuild ctags support
set tags+=./.tags " set tags+=${HOME}/.ctags/*

" wild(mode/menu/ignore) {{{
set wildmenu
set wildmode=longest:full,full                   " alt: wildmode=list:longest
set wildignore+=.git,.svn
set wildignore+=*.bmp,*.gif,*.jpg,*.jpeg,*.png
set wildignore+=*.spl
set wildignore+=*.sw?
set wildignore+=*.orig
set wildignore+=classes
set wildignore+=lib
" }}}

" }}}

" formatting {{{

set autoindent
set smartindent
set smarttab        " sw at start of line, sts everywhere else
set expandtab
set shiftwidth=4
set softtabstop=4
set tabstop=4

" TODO formatoptions, wrap, and textwidth
" soft wrap text - wrap if it doesn't fit in the displayed window
command! -nargs=* Wrap set wrap linebreak nolist

" }}}

" moving / searching {{{

set ignorecase
set smartcase       " case insensitive search becomes sensitive with caps
set gdefault        " all matches in a line are substituted
set hlsearch

" clear highlight search
noremap <silent> <leader><space> :noh<cr>:call clearmatches()<cr>

" use perl regexp instead of vims
nnoremap / /\v
vnoremap / /\v

" make tab useful outside of insert mode
nnoremap <tab> %
vnoremap <tab> %

" <c-]> jumps to tags 
" <c-\> opens the tag in a new split
nnoremap <c-]> <c-]>mzzvzz15<c-e>`z:Pulse<cr>
nnoremap <c-\> <c-w>v<c-]>mzzMzvzz15<c-e>`z:Pulse<cr>

" Keep search matches in the middle of the window.
nnoremap n nzzzv
nnoremap N Nzzzv

" Same when jumping around
nnoremap g; g;zz
nnoremap g, g,zz
nnoremap <c-o> <c-o>zz

nnoremap <C-h> <C-w>h
nnoremap <C-j> <C-w>j
nnoremap <C-k> <C-w>k
nnoremap <C-l> <C-w>l

noremap j gj
noremap k gk
noremap gj j
noremap gk k

inoremap jj <ESC>

" }}}

" folding {{{

set foldlevelstart=1

" space to toggle folds
nnoremap <Space> za
vnoremap <Space> za

" zO to recursively open top level fold
nnoremap zO zCzO

" focus the current line in nested folds
nnoremap z<Enter> mzzMzvzz15<c-e>`z:Pulse<cr>

function! CustomFolds() " {{{
    let nucolwidth = &fdc + &number * &numberwidth
    let windowwidth = winwidth(0) - nucolwidth - 3
    let foldedlinecount = (v:foldend - v:foldstart) + 1

    let onetab = strpart('          ', 0, &tabstop)
    let line = substitute(getline(v:foldstart), '\t', onetab, 'g')
    let line = strpart(line, 0, windowwidth - 2 -len(foldedlinecount))
    let fillcharcount = windowwidth - len(line) - len(foldedlinecount)
    return line . ' (' . foldedlinecount . ')' . repeat(" ",fillcharcount)
endfunction " }}}
set foldtext=CustomFolds()

" }}}

" functions {{{

function! CreateDirIfNecessary(dir)
    if !isdirectory(expand(a:dir))
        call mkdir(expand(a:dir), "p")
    endif
endfunction

function! Chomp(str)
    return substitute(a:str, '\n$', '', '')
endfunction

function! FormatJavaScript()
    :%s/;/;\r/gc
    :%s/}/}\r/gc
    :%s/{/{\r/gc
endfun

function! OpenURL(url) " {{{
  if has("win32")
    exe "!start cmd /cstart /b ".a:url.""
  elseif $DISPLAY !~ '^\w'
    exe "silent !sensible-browser \"".a:url."\""
  else
    exe "silent !sensible-browser -T \"".a:url."\""
  endif
  redraw!
endfunction
command! -nargs=1 OpenURL :call OpenURL(<q-args>)
" open URL under cursor in browser
nnoremap gb :OpenURL <cfile><CR>
nnoremap gG :OpenURL http://www.google.com/search?q=<cword><CR>
" }}}

function! MarkdownToFirefox()
	if executable("markdown") && (executable("firefox") || executable("google-chrome"))
		let l:target = "/tmp/" . expand("%:t:r") . ".html"
		execute "!markdown " . expand("%") . "> " . l:target
		call OpenURL(l:target)
	else
		echo "Install markdown and a browser"
	endif
endfunction

function! Run() " {{{

	let old_makeprg = &makeprg
	let cmd = matchstr(getline(1),'^#!\zs[^ ]*')
	if exists("b:run_command")
		exe b:run_command
	elseif cmd != '' && executable(cmd)
		wa
		let &makeprg = matchstr(getline(1),'^#!\zs.*').' %'
		make
	elseif &ft == "mail" || &ft == "text" || &ft == "help" || &ft == "gitcommit" || &ft == "markdown"
		setlocal spell!
	elseif exists("b:rails_root") && exists(":Rake")
		wa
		Rake
	elseif &ft == "ruby"
		wa
		if executable(expand("%:p")) || getline(1) =~ '^#!'
			compiler ruby
			let &makeprg = "ruby"
			make %
		elseif expand("%:t") =~ '_(spec|test)\.rb$'
			compiler ruby
			let &makeprg = "ruby"
			make %
		else
			!irb -r"%:p"
		endif
	elseif &ft == "javascript"
		let &makeprg = "node"
		make %
	elseif &ft == "html" || &ft == "xhtml"
		wa
		if !exists("b:url")
			call OpenURL(expand("%:p"))
		else
			call OpenURL(b:url)
		endif
	elseif &ft == "vim"
		wa
		unlet! g:loaded_{expand("%:t:r")}
		return 'source %'
	elseif expand("%:t") == "xmonad.hs"
		let &makeprg = "xmonad --recompile"
		make
	else
		wa
		if &makeprg =~ "%"
			make
		else
			make %
		endif
	endif
	let &makeprg = old_makeprg
	return ""
endfunction
command! -bar Run :execute Run()
" }}}

function! OpenDmenu(command) " {{{
	if executable('dmenu')
		echo "DMenu: listing files"
		if isdirectory(".git")
			let finder = "git ls-files"
		else
			let finder = "find . -type f -maxdepth 3"
		endif
		let dmenu = "|dmenu -i -l 40 -nb '#333' -nf yellow -sb yellow -sf black -p "
		let filename = Chomp(system(finder . dmenu . a:command))
		if !empty(filename)
			execute a:command . " " . filename
		endif
	else
		echohl ErrorMsg | echomsg "dmenu is not available" | echohl None
	endif
endfunction
command! -nargs=0 Tabt :call OpenDmenu("tabe")
" }}}

" Pulse Line {{{

function! s:Pulse()
    let current_window = winnr()
    windo set nocursorline
    execute current_window . 'wincmd w'
    setlocal cursorline

    redir => old_hi
        silent execute 'hi CursorLine'
    redir END
    let old_hi = split(old_hi, '\n')[0]
    let old_hi = substitute(old_hi, 'xxx', '', '')

    let steps = 9
    let width = 1
    let start = width
    let end = steps * width
    let color = 233

    for i in range(start, end, width)
        execute "hi CursorLine ctermbg=" . (color + i)
        redraw
        sleep 6m
    endfor
    for i in range(end, start, -1 * width)
        execute "hi CursorLine ctermbg=" . (color + i)
        redraw
        sleep 6m
    endfor

    setlocal nocursorline

    execute 'hi ' . old_hi
endfunction
command! -nargs=0 Pulse call s:Pulse()

" }}}

" }}}

" swap / undo {{{

set undodir=~/.vim/tmp/undo
set directory=~/.vim/tmp/swap

call CreateDirIfNecessary(&undodir)
call CreateDirIfNecessary(&directory)

" }}}

" mappings {{{

nnoremap <F3>    :tp<CR>
nnoremap <F4>    :ts<CR>
nnoremap <F5>    :tn<CR>
nnoremap <leader>t :call OpenDmenu("e")<cr>
nnoremap <Leader>h :call pathogen#helptags()<cr>
nnoremap <C-F12> :!ctags -R --exclude=.git --exclude=logs --exclude=doc -f .tags .<CR>
nnoremap <leader>g :silent execute "grep! -R " . shellescape(expand("<cWORD>")) . " ."<cr>:copen<cr>

nnoremap <leader>, :Run<CR>
nnoremap <leader>m :messages<cr>

nnoremap <Leader>cd :cd %:p:h<CR>
nnoremap <Leader>lcd :lcd %:p:h<CR>
nnoremap <leader>o :silent execute "!nautilus " . expand("%:h")<cr>

" clean trailing whitespace
nnoremap <leader>w mz:%s/\s\+$//<cr>:let @/=''<cr>`z

" current word to upper
inoremap <C-u> <esc>mzgUiw`za

" view special characters
nnoremap <leader>i :set list!<cr>

" fix screen
nnoremap U :syntax sync fromstart<cr>:redraw!<cr>

" }}}

" autocommands {{{
augroup misc
    au!

    " resize splits on window resize
    au VimResized * :wincmd =

augroup END

augroup line_return
    au!

    au BufReadPost *
        \ if line("'\"") > 0 && line("'\"") <= line("$") |
        \     execute 'normal! g`"zvzz' |
        \ endif
augroup END

" }}}

" filetypes {{{

" CSS and Less {{{

augroup ft_css
    au!

    au BufNewFile,BufRead *.less setlocal filetype=less

    au Filetype less,css setlocal foldmethod=marker foldmarker={,}
    au Filetype less,css setlocal omnifunc=csscomplete#CompleteCSS
    au Filetype less,css setlocal iskeyword+=-

    " use <leader>S to sort properties
    au BufNewFile,BufRead *.less,*.css nnoremap <buffer> <localleader>S ?{<CR>jV/\v^\s*\}?$<CR>k:sort<CR>:noh<CR>

    " {<cr> insert brackets
    au BufNewFile,BufRead *.less,*.css inoremap <buffer> {<cr> {}<left><cr><space><space><space><space>.<cr><esc>kA<bs>
augroup END

" }}}

" Haskell {{{

" TODO fix
" augroup ft_haskell
"     au!
"     au BufEnter *.hs compiler ghc
" augroup END

" }}}

" HTML {{{

augroup ft_html
    au!

    au BufNewFile,BufRead *.html setlocal filetype=html nowrap

    au FileType html setlocal foldmethod=manual

    " Use <localleader>f to fold the current tag.
    au FileType html nnoremap <buffer> <localleader>f Vatzf

    " Use <localleader>t to fold the current templatetag.
    au FileType html nmap <buffer> <localleader>t viikojozf

    " Indent tag
    au FileType html nnoremap <buffer> <localleader>= Vat=

augroup END

" }}}

" Java {{{

augroup ft_java
    au!

    au FileType java setlocal foldmethod=marker foldmarker={,}
augroup END

" }}}

" Javascript {{{

augroup ft_javascript
    au!

    au BufNewFile,BufRead *.json set filetype=javascript

    au FileType javascript setlocal foldmethod=marker foldmarker={,}
    au FileType javascript setlocal ai et sta sw=4 sts=4

    " {<cr> insert brackets
    au Filetype javascript inoremap <buffer> {<cr> {}<left><cr><space><space><space><space>.<cr><esc>kA<bs>

    " TODO incomplete
    nnoremap <leader>fj :call FormatJavaScript()<cr>

augroup END

" }}}

" Markdown {{{

augroup ft_markdown
    au!

    au BufNewFile,BufRead *.markdown,*.md,*.mdown,*.mkd,*.mkdn setlocal filetype=markdown
    
    au Filetype markdown setlocal foldlevel=1 fo+=t
    au Filetype markdown nnoremap <buffer> <localleader>1 mzI#<space><esc>
    au Filetype markdown nnoremap <buffer> <localleader>2 mzI##<space><esc>
    au Filetype markdown nnoremap <buffer> <localleader>3 mzI###<space><esc>

    au FileType markdown nnoremap <buffer> <leader>f :call MarkdownToFirefox()<cr>
augroup END

" }}}

" Nginx {{{

augroup ft_nginx
    au!

    au BufRead,BufNewFile /etc/nginx/conf/*                      set ft=nginx
    au BufRead,BufNewFile /etc/nginx/sites-available/*           set ft=nginx
    au BufRead,BufNewFile /usr/local/etc/nginx/sites-available/* set ft=nginx
    au BufRead,BufNewFile vhost.nginx                            set ft=nginx

    au FileType nginx setlocal foldmethod=marker foldmarker={,}
augroup END

" }}}

" SQL {{{

augroup ft_sql
    au!

    au BufNewFile,BufRead *.sql set filetype=sql
    au FileType sql set foldmethod=indent
    au FileType sql set softtabstop=2 shiftwidth=2
    au FileType sql setlocal commentstring=--\ %s comments=:--
augroup END

" }}}

" Ruby {{{

augroup ft_ruby
    au!

    au BufNewFile,BufRead *.eruby,Vagrantfile setlocal filetype=ruby

    au Filetype ruby setlocal foldmethod=syntax foldlevel=1
    au FileType ruby nnoremap <buffer> <leader>r :!rake spec<CR>
    au FileType ruby setlocal ai et sta sw=2 sts=2
    au BufRead,BufNewFile Capfile setlocal filetype=ruby
    au FileType ruby,eruby let g:rubycomplete_buffer_loading = 1
    au FileType ruby,eruby let g:rubycomplete_classes_in_global = 1
    au FileType ruby,eruby let g:rubycomplete_rails = 1

augroup END

" }}}

" Vim {{{

augroup ft_vim
    au!

    au FileType vim setlocal foldmethod=marker foldlevel=0
    au FileType help setlocal textwidth=80
    " open help to the right!
    au BufWinEnter *.txt if &ft == 'help' | wincmd L | endif
augroup END

" }}}

" YAML {{{

augroup ft_yaml
    au!

    au FileType yaml set shiftwidth=2
augroup END

" }}}

" XML {{{

augroup ft_xml
    au!

    au FileType xml setlocal foldmethod=manual

    " Use <localleader>f to fold the current tag.
    au FileType xml nnoremap <buffer> <localleader>f Vatzf

    " Indent tag
    au FileType xml nnoremap <buffer> <localleader>= Vat=

    au FileType xml exe ":silent 1,$!xmllint --format --recover - 2>/dev/null"
augroup END

" }}}

" }}}

" plugins {{{

" ack.vim
" bufexplorer
" nerdtree
" snipmate
" vim-bundler           https://github.com/tpope/vim-bundler
" vim-endwise
" vim-eunuch
" vim-fugitive
" vim-markdown
" vim-rails
" vim-surround
" mustang.vim
" TODO yankring http://www.vim.org/scripts/script.php?script_id=1234
" TODO vim-dispatch https://github.com/tpope/vim-dispatch
" TODO haskellmode

" Ack {{{

" http://beyondgrep.com/
" apt-get install ack-grep
" TODO see smart-case
nnoremap <leader>a :Ack!<space>

" }}}

" Dispatch {{{

nnoremap <leader>d :Dispatch<cr>

" }}}

" NERD Tree {{{

let NERDTreeDirArrows = 1
let NERDTreeMapJumpFirstChild = 'gK'

nnoremap <leader>e :NERDTreeToggle<CR>
noremap <F2> :NERDTreeToggle<cr>

augroup ps_nerdtree
    au!

    au Filetype nerdtree nnoremap <buffer> H :vertical resize -10<cr>
    au Filetype nerdtree nnoremap <buffer> L :vertical resize +10<cr>
    au Filetype nerdtree setlocal nolist
augroup END

" }}}

" }}}

" colorscheme {{{

" .bashrc should set TERM to xterm-256color when running gnome-terminal
if (&term == "xterm-256color" || has("gui_running")) && has("syntax")
    colorscheme mustang
else
    colorscheme elflord
endif

" }}}

" source local vimrc {{{

if filereadable(expand("~/.vimrc.local"))
    source ~/.vimrc.local
endif

" }}}

