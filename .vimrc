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

" Add plist editing support to Vim
" https://github.com/darfink/vim-plist
Plug 'darfink/vim-plist'

" wisely add "end" in ruby, endfunction/endif/more in vim script
" https://github.com/tpope/vim-endwise
Plug 'tpope/vim-endwise'

" Map '%' to jump from one keyword to its corresponding 'end' in Ruby files.
" http://www.vim.org/scripts/script.php?script_id=290
Plug 'ruby-matchit'

call plug#end()
