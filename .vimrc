set fileencodings=utf-8,euc-jp,cp932
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
set mouse=a
set ttymouse=xterm2
set history=10000
set nomodeline
set hlsearch
set incsearch

runtime macros/matchit.vim

" Jump to the last position when reopening a file
au BufReadPost * if line("'\"") > 1 && line("'\"") <= line("$") | exe "normal! g'\"" | endif

" Avoid typo
nnoremap qq: <Esc>q:
nnoremap qq/ <Esc>q/
nnoremap q: <Nop>
nnoremap q/ <Nop>

call plug#begin('~/.vim/plugged')

" Vim -- Appearance
Plug 'sickill/vim-monokai'
Plug 'nathanaelkane/vim-indent-guides'

" Vim -- Edit
Plug 'w0rp/ale'
Plug 'editorconfig/editorconfig-vim'
Plug 'tomtom/tcomment_vim'
Plug 'vim-scripts/YankRing.vim'

" Vim -- Feature
Plug 'vim-scripts/sudo.vim'
Plug 'tyru/open-browser.vim'
Plug 'fuenor/qfixhowm'
Plug 'houtsnip/vim-emacscommandline'

" Languages -- Ruby
" wisely add "end" in ruby, endfunction/endif/more in vim script
Plug 'tpope/vim-endwise'
Plug 'tpope/vim-rails'

" Languages -- Markup
Plug 'othree/html5.vim'
Plug 'slim-template/vim-slim'
Plug 'previm/previm'

" Languages -- JavaScript
Plug 'leafgarland/typescript-vim'
Plug 'othree/yajs.vim'
Plug 'kchmck/vim-coffee-script'

" Languages -- others
Plug 'hashivim/vim-terraform'
Plug 'fatih/vim-go', { 'do': ':GoUpdateBinaries' }
Plug 'darfink/vim-plist'
Plug 'mechatroner/rainbow_csv'

" Others
if isdirectory(expand('~/github/vim-yamaha'))
  Plug '~/github/vim-yamaha'
end

call plug#end()

colorscheme monokai

let g:ale_fixers = {
\   'ruby': ['rubocop'],
\}

let g:ale_lint_on_text_changed = 0
let g:ale_lint_on_insert_leave = 1

au BufNewFile,BufRead,BufReadPost Capfile set syntax=Ruby
au BufNewFile,BufRead,BufReadPost .envrc set syntax=sh
au BufNewFile,BufRead,BufReadPost *-Dockerfile set syntax=Dockerfile

" QFixHowm
set timeout timeoutlen=3000 ttimeoutlen=100
let QFixHowm_Key = 'g'
let howm_dir = '~/howm'
let howm_filename = '%Y-%m-%d-%H%M%S.md'
let howm_fileencoding = 'utf-8'
let howm_fileformat = 'unix'
let QFixWin_EnableMode = 1
let QFixHowm_SplitMode = 1
let QFixHowm_Title = '#'
let QFixHowm_FileType = 'markdown'

" vim-indent-guides
let g:indent_guides_enable_on_vim_startup = 1
let g:indent_guides_guide_size = 1
let g:indent_guides_start_level = 2
let g:indent_guides_exclude_filetypes = ['help', 'nerdtree']
if !has('gui_running')
  let g:indent_guides_auto_colors = 0
  hi IndentGuidesOdd ctermbg=233
  hi IndentGuidesEven ctermbg=238
endif
