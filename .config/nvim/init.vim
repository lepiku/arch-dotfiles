" Specify a directory for plugins
" - For Neovim: stdpath('data') . '/plugged'
" - Avoid using standard Vim directory names like 'plugin'
if has('nvim')
	call plug#begin(stdpath('data') . '/plugged')
else
	call plug#begin('~/.local/share/nvim/plugged')
endif

" Plugins from github
" Make sure you use single quotes
" On-demand loading
Plug 'airblade/vim-gitgutter'
Plug 'alvan/vim-closetag'
Plug 'dart-lang/dart-vim-plugin'
Plug 'godlygeek/tabular'
Plug 'iamcco/markdown-preview.nvim', { 'do': 'cd app & yarn install'  }
Plug 'jiangmiao/auto-pairs'
Plug 'scrooloose/nerdcommenter'
Plug 'scrooloose/nerdtree', { 'on': 'NERDTreeToggle' }
Plug 'tomasiser/vim-code-dark'
Plug 'tpope/vim-fugitive'
Plug 'tpope/vim-repeat'
Plug 'tpope/vim-surround'
Plug 'vim-airline/vim-airline'
Plug 'Xuyuanp/nerdtree-git-plugin'

if has('nvim')
	Plug 'neoclide/coc.nvim', { 'branch': 'release' }
endif

" Initialize plugin system
call plug#end()
filetype plugin indent on
set encoding=utf-8
set hidden

" change leader key
let mapleader=","

" set defautl tabs to have 4 spaces
set sw=4 ts=4 sts=4 expandtab autoindent

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

" permanent undo and clipboard behaviour
set undofile
set undodir=~/.undodir
set clipboard=unnamed

" wrap text with 'gq'
set textwidth=80

" ------------ coc.nvim settings ----------------- "
" Some servers have issues with backup files, see #649
set nobackup
set nowritebackup

set cmdheight=2
set updatetime=200
" don't give |ins-completion-menu| messages.
set shortmess+=c

if has('nvim')
	" Use tab for trigger completion with characters ahead and navigate.
	" Use command ':verbose imap <tab>' to make sure tab is not mapped by other plugin.
	inoremap <silent><expr> <TAB>
				\ pumvisible() ? "\<C-n>" :
				\ <SID>check_back_space() ? "\<TAB>" :
				\ coc#refresh()
	inoremap <expr><S-TAB> pumvisible() ? "\<C-p>" : "\<C-h>"

	function! s:check_back_space() abort
		let col = col('.') - 1
		return !col || getline('.')[col - 1]  =~# '\s'
	endfunction

	" Use <c-space> to trigger completion.
	inoremap <silent><expr> <c-space> coc#refresh()

	" Use <cr> to confirm completion, `<C-g>u` means break undo chain at current position.
	" Coc only does snippet and additional edit on confirm.
	inoremap <expr> <cr> pumvisible() ? "\<C-y>" : "\<C-g>u\<CR>"
	" Or use `complete_info` if your vim support it, like:
	" inoremap <expr> <cr> complete_info()["selected"] != "-1" ? "\<C-y>" : "\<C-g>u\<CR>"

	" Use `[g` and `]g` to navigate diagnostics
	nmap <silent> [g <Plug>(coc-diagnostic-prev)
	nmap <silent> ]g <Plug>(coc-diagnostic-next)

	" Remap keys for gotos
	nmap <silent> gd <Plug>(coc-definition)
	nmap <silent> gy <Plug>(coc-type-definition)
	nmap <silent> gi <Plug>(coc-implementation)
	nmap <silent> gr <Plug>(coc-references)

	" Use K to show documentation in preview window
	nnoremap <silent> K :call <SID>show_documentation()<CR>
	function! s:show_documentation()
		if (index(['vim','help'], &filetype) >= 0)
			execute 'h '.expand('<cword>')
		else
			call CocAction('doHover')
		endif
	endfunction

	" Highlight symbol under cursor on CursorHold
	autocmd CursorHold * silent call CocActionAsync('highlight')

	" Remap for rename current word
	nmap <leader>rn <Plug>(coc-rename)

	" Remap for format selected region
	xmap <leader>f  <Plug>(coc-format-selected)
	nmap <leader>f  <Plug>(coc-format-selected)

	augroup mygroup
		autocmd!
		" Setup formatexpr specified filetype(s).
		autocmd FileType typescript,json setl formatexpr=CocAction('formatSelected')
		" Update signature help on jump placeholder
		autocmd User CocJumpPlaceholder call CocActionAsync('showSignatureHelp')
	augroup end

	" Remap for do codeAction of selected region, ex: `<leader>aap` for current paragraph
	xmap <leader>a  <Plug>(coc-codeaction-selected)
	nmap <leader>a  <Plug>(coc-codeaction-selected)

	" Remap for do codeAction of current line
	nmap <leader>ac  <Plug>(coc-codeaction)
	" Fix autofix problem of current line
	nmap <leader>qf  <Plug>(coc-fix-current)

	" Create mappings for function text object, requires document symbols feature of languageserver.
	xmap if <Plug>(coc-funcobj-i)
	xmap af <Plug>(coc-funcobj-a)
	omap if <Plug>(coc-funcobj-i)
	omap af <Plug>(coc-funcobj-a)

	" Use <TAB> for select selections ranges, needs server support, like: coc-tsserver, coc-python
	nmap <silent> <TAB> <Plug>(coc-range-select)
	xmap <silent> <TAB> <Plug>(coc-range-select)

	" Use `:Format` to format current buffer
	command! -nargs=0 Format :call CocAction('format')

	" Use `:Fold` to fold current buffer
	command! -nargs=? Fold :call     CocAction('fold', <f-args>)

	" use `:OR` for organize import of current buffer
	command! -nargs=0 OR   :call     CocAction('runCommand', 'editor.action.organizeImport')

	" Add status line support, for integration with other plugin, checkout `:h coc-status`
	set statusline^=%{coc#status()}%{get(b:,'coc_current_function','')}

	" CocCommand shortcut
	nnoremap <silent> <C-P> :CocCommand<CR>
endif

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

" autocomplete highlights
highlight Pmenu ctermbg=236 ctermfg=254
highlight PmenuSel ctermbg=232 ctermfg=252

highlight MatchParen ctermbg=24
highlight Search ctermbg=239 ctermfg=NONE
highlight Visual ctermbg=18

" coc
highlight CocWarningSign ctermfg=172

" ------------ Plugin Settings ------------------- "
" vim-code-dark plugin
let g:airline_theme = 'codedark'

" gitgutter plugin
highlight GitGutterAdd		cterm=bold ctermfg=2
highlight GitGutterDelete	cterm=bold ctermfg=1
highlight GitGutterChange	cterm=bold ctermfg=3
highlight GitGutterText		cterm=bold ctermfg=5

" vim-fugitive plugin
highlight DiffAdd		cterm=NONE ctermbg=17
highlight DiffDelete	cterm=NONE ctermbg=17 ctermfg=1
highlight DiffChange	cterm=NONE ctermbg=17
highlight DiffText		cterm=NONE ctermbg=52

" error color
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

" reload vimrc
if has('nvim')
	nnoremap <Leader>rr :source ~/.config/nvim/init.vim<CR>
else
	nnoremap <Leader>rr :source ~/.vimrc<CR>
endif

" hide search results
map <Esc><Esc> :nohlsearch<CR>

" undo branching
noremap <C-n> g-
noremap <C-m> g+

if has('clipboard')
	" copy with CTRL-C
	vnoremap <C-c> "+y
endif

" FZF
noremap <C-z> :call fzf#run(fzf#wrap({'source': '$FZF_VIM_COMMAND'}))<CR>

" NERDTree plugin
noremap <Leader>n :NERDTreeToggle<CR>

" vim fugitive
noremap <Leader>gs :G<CR>
noremap <Leader>gd :Gdiff<CR>

" open terminal like vscode
noremap <silent> <C-Space> :10 split \| term<CR> A

" trim whitespace
nmap <Leader>trim :%s/\ \+$//<CR>

"------------ Config for filetypes -------------- "
" pandoc , markdown
command! -nargs=* RunSilent
			\| execute ':silent !'.'<args>'
			\| execute ':redraw!'
"nmap <Leader>pp :RunSilent pandoc -o /tmp/vim-pandoc-out.pdf "%"<CR>
"nmap <Leader>pe :RunSilent evince /tmp/vim-pandoc-out.pdf<CR>

augroup extension
	au!
	" force indentation
	autocmd BufRead,BufNewFile *.html,*.css,*.js,*.jsx,*.json setlocal sw=2 ts=2 sts=2 expandtab
	" force filetypes
	autocmd BufRead,BufNewFile *.jsx,*js setlocal filetype=javascript
	autocmd BufRead,BufNewFile *.mdx setlocal filetype=markdown
augroup end

augroup postWrite
	au!
	" auto reload vimrc
	autocmd BufWritePost .vimrc source ~/.vimrc
	" xrdb autoload .Xresources
	autocmd BufWritePost .Xresources silent !xrdb ~/.Xresources
augroup end
