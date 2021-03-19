syntax on

set noerrorbells
set tabstop=4 softtabstop=4
set shiftwidth=4
set expandtab
set guicursor=
set nohlsearch
set hidden
set nu rnu
set nowrap
set smartcase
set noswapfile
set nobackup
set undodir=~/.vim/undodir
set undofile
set incsearch
set scrolloff=8
set smartindent
set nocompatible
set signcolumn=yes
set termguicolors

filetype plugin on

set colorcolumn=80
highlight ColorColumn ctermbg=0 guibg=lightgrey

" Start the list of vim plugins
call plug#begin("~/.config/nvim/plugged")

Plug 'gruvbox-community/gruvbox'
Plug 'vim-ruby/vim-ruby'
Plug 'iamcco/markdown-preview.nvim', { 'do': { -> mkdp#util#install() }, 'for': ['markdown', 'vim-plug']}
Plug 'godlygeek/tabular'
Plug 'plasticboy/vim-markdown'
Plug 'jremmen/vim-ripgrep'
Plug 'tpope/vim-fugitive'
Plug 'tpope/vim-eunuch'
Plug 'tpope/vim-commentary'
Plug 'tpope/vim-surround'
Plug 'leafgarland/typescript-vim'
Plug 'vim-utils/vim-man'
Plug 'lyuts/vim-rtags'
Plug 'kien/ctrlp.vim'
Plug 'Valloric/YouCompleteMe'
Plug 'mbbill/undotree'
Plug 'junegunn/fzf', { 'do' : { -> fzf#install() }}
Plug 'junegunn/fzf.vim'
Plug 'skywind3000/asynctasks.vim'
Plug 'skywind3000/asyncrun.vim'
Plug 'rhysd/vim-clang-format'
Plug 'liuchengxu/vista.vim'
Plug 'preservim/tagbar'
Plug 'vim-airline/vim-airline'
Plug 'vim-airline/vim-airline-themes'
Plug 'vimwiki/vimwiki'
" Plug 'SirVer/ultisnips'
" Plug 'honza/vim-snippets'
" Plug 'ervandew/supertab'
" Plug 'garbas/vim-snipmate'
Plug 'MarcWeber/vim-addon-mw-utils'
Plug 'tomtom/tlib_vim'
Plug 'dbakker/vim-projectroot'
Plug 'vim-scripts/DoxygenToolkit.vim'
" Plug 'dbeniamine/cheat.sh-vim'
Plug 'MarcWeber/vim-addon-local-vimrc'
" Debugger plugins
" Plug 'puremourning/vimspector'
Plug 'szw/vim-maximizer'
"Plug 'neoclide/coc.nvim', {'branch': 'release'}
Plug 'lervag/vimtex'
Plug 'ekalinin/dockerfile.vim'
Plug 'Chiel92/vim-autoformat'
" Plug 'ludovicchabant/vim-gutentags'
Plug 'edkolev/tmuxline.vim'

call plug#end()
packloadall
colorscheme gruvbox
set background=dark
highlight Normal guibg=none

let g:airline_powerline_fonts = 1

if executable('rg')
    let g:rg_derive_root='true'
endif

" Asynctasks
let g:asyncrun_open = 6
let g:asynctasks_term_rows = 40 " set height for the horizontal terminal split
let g:asynctasks_term_pos = 'external'
nnoremap <F2> :AsyncTask task1<CR>
nnoremap <F3> :AsyncTask task2<CR>
nnoremap <F4> :AsyncTask task3<CR>
nnoremap <F5> :AsyncTask task4<CR>

let g:ctrlp_user_command = ['.git/', 'git --git-dir=%s/.git ls-files -oc --exclude-stand']
let mapleader = " "
let g:netrw_browse_split=2
let g:netrw_banner=0
let g:netrw_winsize=25
let g:ctrlp_use_caching=0

" Navigation
nnoremap <leader>h :wincmd h<CR>
nnoremap <leader>j :wincmd j<CR>
nnoremap <leader>k :wincmd k<CR>
nnoremap <leader>l :wincmd l<CR>
nnoremap <leader>pv :wincmd v<bar> :Ex <bar> :vertical resize 30<CR>
nnoremap <silent> <leader>+ :vertical resize +5<CR>
nnoremap <silent> <leader>- :vertical resize -5<CR>
nnoremap <leader>z :MaximizerToggle <CR>
nnoremap <C-k> :cprevious<CR>
nnoremap <C-j> :cnext<CR>
nnoremap <silent> <Leader>ln :lnext<CR>
nnoremap <silent> <Leader>lp :lprevious<CR>
imap jj <Esc>

"gfiles, rg, undotree, fugitive
nnoremap <leader>u :UndotreeShow<CR>
nnoremap <leader>ps :Rg<SPACE>
nnoremap <leader>pf :Rg<SPACE><c-r><c-w>
nnoremap <C-p> :GFiles<CR>
nnoremap <leader>b :Gblame<CR>

" YCM
nnoremap <silent> <Leader>gd :YcmCompleter GoTo<CR>
nnoremap <silent> <Leader>gr :YcmCompleter GoToReferences<CR>
nnoremap <silent> <Leader>gf :YcmCompleter FixIt<CR>
nnoremap <Leader>grr :YcmCompleter RefactorRename<SPACE>
if !exists('g:ycm_semantic_triggers')
    let g:ycm_semantic_triggers = {}
endif
au VimEnter * let g:ycm_semantic_triggers.tex=g:vimtex#re#youcompleteme

" Tagbar
nmap <F8> :TagbarToggle<CR>

" Snippets
"let g:UltiSnipsExpandTrigger="<tab>"

" Closing parenthesis, etc.
" inoremap " ""<left>
" inoremap ' ''<left>
" inoremap ( ()<left>
" inoremap [ []<left>
" inoremap { {}<left>
" inoremap {<CR> {<CR>}<ESC>O
" inoremap {;<CR> {<CR>};<ESC>O

" Copy to clipboard
vnoremap  <leader>y  "+y
nnoremap  <leader>Y  "+yg_
nnoremap  <leader>y  "+y
nnoremap  <leader>yy  "+yy

" Paste from clipboard
nnoremap <leader>p "+p
nnoremap <leader>P "+P
vnoremap <leader>p "+p
vnoremap <leader>P "+P

" Move selected text
vnoremap J :m '>+1<CR>gv=gv
vnoremap K :m '<-2<CR>gv=gv

" Doxygen
let g:DoxygenToolkit_briefTag_pre="@Synopsis  "
let g:DoxygenToolkit_paramTag_pre="@Param "
let g:DoxygenToolkit_returnTag="@Returns   "
let g:DoxygenToolkit_blockHeader="-------------------------------"
let g:DoxygenToolkit_blockFooter="---------------------------------"
let g:DoxygenToolkit_authorName="Harald Lilja"
let g:DoxygenToolkit_licenseTag="My own license" 

" Indent fix for yml files
autocmd FileType yaml setlocal ts=2 sts=2 sw=2 expandtab

" Allow saving of files as sudo when I forgot to start vim using sudo.
cmap w!! w !sudo tee > /dev/null %

" XML formatting
function! DoPrettyXML()
  " save the filetype so we can restore it later
  let l:origft = &ft
  set ft=
  " delete the xml header if it exists. This will
  " permit us to surround the document with fake tags
  " without creating invalid xml.
  1s/<?xml .*?>//e
  " insert fake tags around the entire document.
  " This will permit us to pretty-format excerpts of
  " XML that may contain multiple top-level elements.
  0put ='<PrettyXML>'
  $put ='</PrettyXML>'
  silent %!xmllint --format -
  " xmllint will insert an <?xml?> header. it's easy enough to delete
  " if you don't want it.
  " delete the fake tags
  2d
  $d
  " restore the 'normal' indentation, which is one extra level
  " too deep due to the extra tags we wrapped around the document.
  silent %<
  " back to home
  1
  " restore the filetype
  exe "set ft=" . l:origft
endfunction
command! PrettyXML call DoPrettyXML()
