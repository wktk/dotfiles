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

" Shortcut to :noh
nnoremap <Esc><Esc> :noh<CR>

" Hold Visual mode after pressing < or >
vnoremap < <gv
vnoremap > >gv

call plug#begin('~/.vim/plugged')

" Vim -- Appearance
Plug 'sickill/vim-monokai'
Plug 'nathanaelkane/vim-indent-guides'

" Vim -- Edit
Plug 'w0rp/ale'
Plug 'editorconfig/editorconfig-vim'
Plug 'tomtom/tcomment_vim'
Plug 'vim-scripts/YankRing.vim'
Plug 'tpope/vim-surround'

" Vim -- Completion
Plug 'Shougo/neocomplete.vim'

" Vim -- Feature
Plug 'vim-scripts/sudo.vim'
Plug 'tyru/open-browser.vim'
Plug 'fuenor/qfixhowm'
Plug 'houtsnip/vim-emacscommandline'
Plug 'christoomey/vim-tmux-navigator'

" Languages -- Ruby
Plug 'tpope/vim-endwise'
Plug 'tpope/vim-rails'
Plug 'todesking/ruby_hl_lvar.vim'

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

" neocomplete -- dict for Ruby & JS
let s:neco_dicts_dir = '~/.vim/dicts'
if isdirectory(s:neco_dicts_dir)
  let g:neocomplete#sources#dictionary#dictionaries = {
  \   'ruby': s:neco_dicts_dir . '/ruby.dict',
  \   'javascript': s:neco_dicts_dir . '/jquery.dict',
  \ }
endif

" neocomplete.vim {{{
" https://github.com/Shougo/neocomplete.vim

" Disable AutoComplPop.
let g:acp_enableAtStartup = 0
" Use neocomplete.
let g:neocomplete#enable_at_startup = 1
" Use smartcase.
let g:neocomplete#enable_smart_case = 1
" Set minimum syntax keyword length.
let g:neocomplete#sources#syntax#min_keyword_length = 3

" Define dictionary.
let g:neocomplete#sources#dictionary#dictionaries = {
    \ 'default' : '',
    \ 'vimshell' : $HOME.'/.vimshell_hist',
    \ 'scheme' : $HOME.'/.gosh_completions'
        \ }

" Define keyword.
if !exists('g:neocomplete#keyword_patterns')
    let g:neocomplete#keyword_patterns = {}
endif
let g:neocomplete#keyword_patterns['default'] = '\h\w*'

" Plugin key-mappings.
inoremap <expr><C-g>     neocomplete#undo_completion()
inoremap <expr><C-l>     neocomplete#complete_common_string()

" Recommended key-mappings.
" <CR>: close popup and save indent.
inoremap <silent> <CR> <C-r>=<SID>my_cr_function()<CR>
function! s:my_cr_function()
  return (pumvisible() ? "\<C-y>" : "" ) . "\<CR>"
  " For no inserting <CR> key.
  "return pumvisible() ? "\<C-y>" : "\<CR>"
endfunction
" <TAB>: completion.
inoremap <expr><TAB>  pumvisible() ? "\<C-n>" : "\<TAB>"
" <C-h>, <BS>: close popup and delete backword char.
inoremap <expr><C-h> neocomplete#smart_close_popup()."\<C-h>"
inoremap <expr><BS> neocomplete#smart_close_popup()."\<C-h>"
" Close popup by <Space>.
"inoremap <expr><Space> pumvisible() ? "\<C-y>" : "\<Space>"

" AutoComplPop like behavior.
"let g:neocomplete#enable_auto_select = 1

" Shell like behavior(not recommended).
"set completeopt+=longest
"let g:neocomplete#enable_auto_select = 1
"let g:neocomplete#disable_auto_complete = 1
"inoremap <expr><TAB>  pumvisible() ? "\<Down>" : "\<C-x>\<C-u>"

" Enable omni completion.
autocmd FileType css setlocal omnifunc=csscomplete#CompleteCSS
autocmd FileType html,markdown setlocal omnifunc=htmlcomplete#CompleteTags
autocmd FileType javascript setlocal omnifunc=javascriptcomplete#CompleteJS
autocmd FileType python setlocal omnifunc=pythoncomplete#Complete
autocmd FileType xml setlocal omnifunc=xmlcomplete#CompleteTags

" Enable heavy omni completion.
if !exists('g:neocomplete#sources#omni#input_patterns')
  let g:neocomplete#sources#omni#input_patterns = {}
endif
"let g:neocomplete#sources#omni#input_patterns.php = '[^. \t]->\h\w*\|\h\w*::'
"let g:neocomplete#sources#omni#input_patterns.c = '[^.[:digit:] *\t]\%(\.\|->\)'
"let g:neocomplete#sources#omni#input_patterns.cpp = '[^.[:digit:] *\t]\%(\.\|->\)\|\h\w*::'

" For perlomni.vim setting.
" https://github.com/c9s/perlomni.vim
let g:neocomplete#sources#omni#input_patterns.perl = '\h\w*->\h\w*\|\h\w*::'

" }}}

" vim:set foldmethod=marker :
