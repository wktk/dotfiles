set fileencodings=utf-8,cp932
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
set backspace=indent,eol,start
runtime macros/matchit.vim

call plug#begin('~/.vim/plugged')

" Add plist editing support to Vim
" https://github.com/darfink/vim-plist
Plug 'darfink/vim-plist'

" wisely add "end" in ruby, endfunction/endif/more in vim script
" https://github.com/tpope/vim-endwise
Plug 'tpope/vim-endwise'

" HTML5 + inline SVG omnicomplete function, indent and syntax for Vim.
" https://github.com/othree/html5.vim
Plug 'othree/html5.vim'

" Syntax highlight for Slim
" https://github.com/slim-template/vim-slim
Plug  'slim-template/vim-slim'

" Markdown preview
Plug 'previm/previm'

" JS Syntax highlight
Plug 'othree/yajs.vim'

" Open URI with browser
Plug 'tyru/open-browser.vim'

Plug 'kchmck/vim-coffee-script'

" Asynchronous Lint Engine
Plug 'w0rp/ale'

Plug 'fatih/vim-go', { 'do': ':GoUpdateBinaries' }

Plug 'mechatroner/rainbow_csv'

Plug 'sickill/vim-monokai'

call plug#end()

colorscheme monokai
