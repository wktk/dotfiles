syntax on
set number
set smartindent
set expandtab
set shiftwidth=2
set softtabstop=2
set autoindent
set encoding=utf-8
set cursorline
set cursorcolumn

call plug#begin('~/.vim/plugged')
Plug 'darfink/vim-plist'

" wisely add "end" in ruby, endfunction/endif/more in vim script
" https://github.com/tpope/vim-endwise
Plug 'tpope/vim-endwise'
call plug#end()
