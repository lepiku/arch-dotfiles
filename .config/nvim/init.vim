" Specify a directory for plugins
" - For Neovim: stdpath('data') . '/plugged'
" - Avoid using standard Vim directory names like 'plugin'
call plug#begin(stdpath('data') . '/plugged')

" Plugins from github
" Make sure you use single quotes
" On-demand loading
Plug 'scrooloose/nerdtree', { 'on':  'NERDTreeToggle' }
Plug 'Xuyuanp/nerdtree-git-plugin'
Plug 'airblade/vim-gitgutter'
Plug 'tpope/vim-fugitive'
Plug 'w0rp/ale'
Plug 'ycm-core/YouCompleteMe'
Plug 'vim-airline/vim-airline'
Plug 'scrooloose/nerdcommenter'
Plug 'tpope/vim-surround'
Plug 'tpope/vim-repeat'
Plug 'jiangmiao/auto-pairs'
Plug 'alvan/vim-closetag'
Plug 'tomasiser/vim-code-dark'
Plug 'godlygeek/tabular'
" Initialize plugin system
call plug#end()
filetype plugin indent on
set encoding=utf-8
set hidden

" set defautl tabs to have 4 spaces
set sw=4 ts=4 sts=4 noexpandtab autoindent

" show the matching part of the pair for [] {} and ()
set showmatch

" enable all Python syntax highlighting features
let g:python3_host_prog = '/home/dimas/.conda/envs/neovim3/bin/python'
let python_highlight_all = 1

" add border at 80 column
set colorcolumn=80

" Set the minimal number of lines under the cursor
set scrolloff=2

" Set so vim search (/ or ?) be case insensitive
set ignorecase smartcase

" highlight all search matches
set hlsearch
set incsearch

" Set hybrid line number
set number relativenumber

" Enable autocomplete (enabled by neovim)
"set wildmenu
"set wildmode=longest:list,full

" Set new split below or right
set splitbelow splitright

" ignore autocomplete *.class files
set wildignore=*.class

" navigate with mouse
set mouse=a

" show special characters
set list
set listchars=tab:›\ ,nbsp:␣,trail:•,extends:»,precedes:«
set fillchars+=vert:│

" tell vim where to put swap files
set dir=~/.swapdir

" italic fonts in urxvt
"set term=rxvt-unicode-256color
set conceallevel=2

" permanent undo
set undofile
set undodir=~/.undodir

" ------------ Highlight/Color/Theme ------------- "
colorscheme default
set background=dark
highlight Normal guibg=black guifg=white
highlight SignColumn ctermbg=NONE

" 80 char border
highlight colorcolumn ctermbg=235

" hybrid line number
highlight CursorLineNR cterm=NONE ctermfg=214

" vertical split
highlight VertSplit cterm=NONE ctermfg=123

" comment color
highlight Comment ctermfg=248

" YouCompleteMe highlights
highlight Pmenu ctermbg=236 ctermfg=254
highlight PmenuSel ctermbg=232 ctermfg=252

highlight MatchParen ctermbg=24
highlight Search ctermbg=239 ctermfg=NONE
highlight Visual ctermbg=18

" ------------ Plugin Settings ------------------- "
" ALE plugin settings
let g:ale_linters = {
	\ 'javascript': ['eslint'],
	\ 'python': ['pylint'],
	\}
let g:ale_fixers = {
	\ 'javascript': ['prettier', 'eslint'],
	\ 'python': ['isort', 'autopep8'],
	\}
"let g:ale_python_pylint_options = '--load-plugins pylint_django -d missing-docstring'
let g:ale_python_pylint_options = '-d missing-docstring'
let g:ale_fix_on_save = 1

" YouCompleteMe settings with django
let g:ycm_collect_identifiers_from_tags_files = 1 " Let YCM read tags from Ctags file
let g:ycm_use_ultisnips_completer = 1 " Default 1, just ensure
let g:ycm_seed_identifiers_with_syntax = 1 " Completion for programming language's keyword
let g:ycm_confirm_extra_conf = 0 " disable asking extra conf everytime

" vim-code-dark plugin
let g:airline_theme = 'codedark'

" gitgutter plugin
set updatetime=200
highlight GitGutterAdd		cterm=bold ctermfg=2
highlight GitGutterDelete	cterm=bold ctermfg=1
highlight GitGutterChange	cterm=bold ctermfg=3
highlight GitGutterText		cterm=bold ctermfg=5

" vim-fugitive plugin
highlight DiffAdd		cterm=NONE ctermbg=17
highlight DiffDelete	cterm=NONE ctermbg=17 ctermfg=1
highlight DiffChange	cterm=NONE ctermbg=17
highlight DiffText		cterm=NONE ctermbg=52

" ale plugin
let g:ale_set_signs = 0
highlight error ctermbg=88
highlight SpellBad ctermbg=88
highlight todo ctermbg=100
highlight SpellCap ctermbg=100

" airline plugin
if !exists('g:airline_symbols')
	let g:airline_symbols = {}
endif
let g:airline_left_sep = ''
let g:airline_left_alt_sep = ''
let g:airline_right_sep = ''
let g:airline_right_alt_sep = ''
let g:airline_symbols.branch = ''
let g:airline_symbols.readonly = ''
let g:airline_symbols.linenr = '☰'
let g:airline_symbols.maxlinenr = ''
let g:airline#extensions#hunks#enabled = 0
let g:airline#extensions#tabline#enabled = 1

" NERDTree ignore
let NERDTreeIgnore = ['\.pyc$', '\.class']

" closetag
let g:closetag_filenames = '*.html,*.xhtml,*.phtml,*.js,*.jsx'

" ------------ Mapping / Remaped keys ------------ "
" change leader key
let mapleader=","

" change indent in visual mode
vnoremap > >gv
vnoremap < <gv

" file binding
noremap <S-z><S-a> :wa<CR>
noremap <C-q> :q<CR>

" split binding
noremap <C-S-h> gT
noremap <C-S-l> gt

noremap <C-h> <C-w>h
noremap <C-j> <C-w>j
noremap <C-k> <C-w>k
noremap <C-l> <C-w>l

" resize splits with arrow keys
noremap <C-Left>	:vertical:resize -1<CR>
noremap <C-Down>	:resize +1<CR>
noremap <C-Up>		:resize -1<CR>
noremap <C-Right>	:vertical:resize +1<CR>

" FZF
noremap <C-z> :call fzf#run(fzf#wrap({'source': '$FZF_VIM_COMMAND'}))<CR>

" NERDTree plugin
noremap <Leader>n :NERDTreeToggle<CR>

" ALE warp to next error
nnoremap <Leader>j :ALENextWrap<CR>
nnoremap <Leader>k :ALEPreviousWrap<CR>
" ALE Fixes
nnoremap <Leader>trim :ALEFix trim_whitespace<CR>
map <Leader>fix :ALEFix<CR>

" reload vimrc
nnoremap <Leader>rr :source ~/.config/nvim/init.vim<CR>

" hide search results
map <Esc><Esc> :nohlsearch<CR>

" vim fugitive
map <Leader>gs :G<CR>
map <Leader>gd :Gdiff<CR>

" YouCompleteMe
map <Leader>gt :YcmCompleter GoTo<CR>

" ------------ Config for filetypes -------------- "
" pandoc , markdown
command! -nargs=* RunSilent
	\| execute ':silent !'.'<args>'
	\| execute ':redraw!'
nmap <Leader>pp :RunSilent pandoc -o /tmp/vim-pandoc-out.pdf "%"<CR>
nmap <Leader>pe :RunSilent evince /tmp/vim-pandoc-out.pdf<CR>

augroup extension
	au!
	" force indentation
	autocmd BufRead,BufNewFile *.html,*.css,*.js,*.jsx setlocal sw=2 ts=2 sts=2 expandtab
	" force filetypes
	autocmd BufRead,BufNewFile *.jsx,*js setlocal filetype=javascript
	autocmd BufRead,BufNewFile *.mdx setlocal filetype=markdown
augroup end

augroup postWrite
	au!
	" auto reload vimrc
	autocmd BufWritePost .vimrc source ~/.vimrc
	" groff pdf
	"autocmd BufWritePost *.me !groff -Tps -me '%' > '%:r.pdf'
	" xrdb autoload .Xresources
	autocmd BufWritePost .Xresources silent !xrdb ~/.Xresources
augroup end
