" install pathogen under ~/.vim/autoload
call pathogen#infect()
syntax on
filetype plugin indent on

set nocompatible
set autoindent
set hidden  		" hide buffers instead of closing them
set laststatus=2 	"always show status line
set modelines=5 	" debian likes to disable this in insert mode
set number
set pastetoggle=<F2>
set ignorecase
set scrolloff=1 	" show context around current line
set shiftwidth=4
set showcmd
set showmatch
set smartcase       " case insensitive search becomes sensitive with caps
set smartindent
set smarttab        " sw at start of line, sts everywhere else
set statusline=[%n]\ %<%.99f\ %h%w%m%r%{exists('*CapsLockStatusline')?CapsLockStatusline():''}%y%{exists('*rails#statusline')?rails#statusline():''}%{exists('*fugitive#statusline')?fugitive#statusline():''}%#ErrorMsg#%{exists('*SyntasticStatuslineFlag')?SyntasticStatuslineFlag():''}%*%=%-16(\ %l,%c-%v\ %)%P
set tabstop=4
" set tags+=${HOME}/.ctags/*
set tags+=./.tags
set foldlevel=1
set virtualedit=block
set visualbell
set wildmenu
set wildmode=longest:full,full

function! Run()
	let old_makeprg = &makeprg
	let cmd = matchstr(getline(1),'^#!\zs[^ ]*')
	if exists("b:run_command")
		exe b:run_command
	elseif cmd != '' && executable(cmd)
		wa
		let &makeprg = matchstr(getline(1),'^#!\zs.*').' %'
		make
	elseif &ft == "mail" || &ft == "text" || &ft == "help" || &ft == "gitcommit"
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
		elseif expand("%:t") =~ '_test\.rb$'
			compiler rubyunit
			let &makeprg = "ruby"
			make %
		elseif expand("%:t") =~ '_spec\.rb$'
			compiler ruby
			let &makeprg = "ruby"
			make %
		else
			!irb -r"%:p"
		endif
	elseif &ft == "javascript"
		!node "%:p"
	elseif &ft == "html" || &ft == "xhtml" || &ft == "php" || &ft == "aspvbs" || &ft == "aspperl"
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
	elseif expand("%") == "xmonad.hs"
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

function! OpenURL(url)
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

function! FormatJavaScript()   
    :%s/;/;\r/gc
    :%s/}/}\r/gc
    :%s/{/{\r/gc
endfun
nnoremap <leader>fj :call FormatJavaScript()<cr>

let mapleader=","
map <Leader>v :so ~/.vimrc<CR>
map <F3>    :tp<CR>
map <F4>    :ts<CR>
map <F5>    :tn<CR>
map <leader>, :Run<CR>
map <Leader>h :call pathogen#helptags()
map <Leader>cd :cd %:p:h<CR>
map <Leader>lcd :lcd %:p:h<CR>
map <leader>fi :setlocal foldmethod=indent<cr>
map <leader>fs :setlocal foldmethod=syntax<cr>
map <leader>e :NERDTreeToggle<CR>
map <leader>t :TlistToggle<CR>
map <C-F12> :!ctags -R --exclude=.git --exclude=logs --exclude=doc -f .tags .<CR>
nnoremap <leader>m :messages<cr>
nnoremap <leader>r :!rake spec<CR>
nnoremap <leader>s :source %<cr>
nnoremap <leader>g :silent execute "grep! -R " . shellescape(expand("<cWORD>")) . " ."<cr>:copen<cr>


if exists(":TlistOpen")
	nnoremap <silent> <F6> <ESC>:TlistToggle<CR>
endif

if has("autocmd")
	augroup custom
		filetype plugin indent on
		au BufRead,BufNewFile *.rb setlocal tags+=~/.vim/tags/ruby_and_gems
		autocmd FileType eruby,yaml,ruby        setlocal ai et sta sw=2 sts=2
		autocmd FileType javascript             setlocal ai et sta sw=4 sts=4
		autocmd BufNewFile,BufRead *.json set ft=javascript
		au FileType xml exe ":silent 1,$!xmllint --format --recover - 2>/dev/null"
		autocmd FileType * if exists("+omnifunc") && &omnifunc == "" | setlocal omnifunc=syntaxcomplete#Complete | endif
		autocmd FileType * if exists("+completefunc") && &completefunc == "" | setlocal completefunc=syntaxcomplete#Complete | endif
		autocmd BufNewFile,BufRead *.html setlocal nowrap
	augroup END
endif

" .bashrc should set TERM to xterm-256color when running gnome-terminal
if (&term == "xterm-256color" || has("gui_running")) && has("syntax")
    colorscheme mustang
else
    colorscheme elflord
endif

if filereadable(expand("~/.vimrc.local"))
	source ~/.vimrc.local
endif

function! Chomp(str)
    return substitute(a:str, '\n$', '', '')
endfunction

function! OpenDmenu(command)
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
nnoremap <c-t> :call OpenDmenu("e")<cr>
command! -nargs=0 Tabt :call OpenDmenu("tabe")
