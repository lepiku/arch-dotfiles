" Specify a directory for plugins
" - For Neovim: stdpath('data') . '/plugged'
" - Avoid using standard Vim directory names like 'plugin'
if has('nvim')
    let g:datapath = stdpath('data')
else
    let g:datapath = $HOME . '/.vim'
endif

call plug#begin(g:datapath . '/plugged')

" Plugins from github
" Make sure you use single quotes
" On-demand loading
Plug 'airblade/vim-gitgutter'
Plug 'alvan/vim-closetag'
Plug 'dart-lang/dart-vim-plugin'
Plug 'godlygeek/tabular'
Plug 'jiangmiao/auto-pairs'
Plug 'leafOfTree/vim-vue-plugin'
Plug 'preservim/vim-markdown'
Plug 'rrethy/vim-hexokinase', { 'do': 'make hexokinase' }
Plug 'scrooloose/nerdcommenter'
Plug 'tomasiser/vim-code-dark'
Plug 'tpope/vim-fugitive'
Plug 'tpope/vim-repeat'
Plug 'tpope/vim-surround'
Plug 'vim-airline/vim-airline'
Plug 'vim-test/vim-test'

if has('nvim')
    Plug 'iamcco/markdown-preview.nvim', { 'do': 'cd app && npm install'  }
    Plug 'neoclide/coc.nvim', { 'branch': 'release' }

    let g:coc_global_extensions = [
                \'coc-clangd',
                \'coc-css',
                \'coc-emmet',
                \'coc-eslint',
                \'coc-explorer',
                \'coc-flutter',
                \'coc-go',
                \'coc-html',
                \'coc-java',
                \'coc-jedi',
                \'coc-json',
                \'coc-markdownlint',
                \'coc-prettier',
                \'coc-pyright',
                \'coc-tsserver',
                \'coc-vue',
                \'@yaegassy/coc-volar',
                \]
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

" permanent undo and clipboard behaviour
set undofile
set undodir=~/.undodir
set clipboard=unnamed

" wrap text with 'gq'
"set textwidth=80

" Enable true color support.
set termguicolors
let &t_8f = "\<Esc>[38;2;%lu;%lu;%lum"
let &t_8b = "\<Esc>[48;2;%lu;%lu;%lum"
let g:Hexokinase_highlighters = ['backgroundfull']

" vim-markdown
let g:vim_markdown_folding_disabled = 1
" https://github.com/preservim/vim-markdown#syntax-concealing
set conceallevel=0

" ------------ coc.nvim settings ----------------- "
" https://github.com/neoclide/coc.nvim#example-vim-configuration
if has('nvim')
    " Some servers have issues with backup files, see #649.
    set nobackup
    set nowritebackup

    " Having longer updatetime (default is 4000 ms = 4 s) leads to noticeable
    " delays and poor user experience.
    set updatetime=200

    " Always show the signcolumn, otherwise it would shift the text each time
    " diagnostics appear/become resolved.
    set signcolumn=yes

    " Use tab for trigger completion with characters ahead and navigate.
    " NOTE: There's always complete item selected by default, you may want to enable
    " no select by `"suggest.noselect": true` in your configuration file.
    " NOTE: Use command ':verbose imap <tab>' to make sure tab is not mapped by
    " other plugin before putting this into your config.
    inoremap <silent><expr> <TAB>
          \ coc#pum#visible() ? coc#pum#next(1) :
          \ CheckBackspace() ? "\<Tab>" :
          \ coc#refresh()
    inoremap <expr><S-TAB> coc#pum#visible() ? coc#pum#prev(1) : "\<C-h>"

    " Make <CR> to accept selected completion item or notify coc.nvim to format
    " <C-g>u breaks current undo, please make your own choice.
    inoremap <silent><expr> <CR> coc#pum#visible() ? coc#pum#confirm()
                                  \: "\<C-g>u\<CR>\<c-r>=coc#on_enter()\<CR>"

    function! CheckBackspace() abort
      let col = col('.') - 1
      return !col || getline('.')[col - 1]  =~# '\s'
    endfunction

    " Use <c-space> to trigger completion.
    if has('nvim')
      inoremap <silent><expr> <c-space> coc#refresh()
    else
      inoremap <silent><expr> <c-@> coc#refresh()
    endif

    " Use `[g` and `]g` to navigate diagnostics
    " Use `:CocDiagnostics` to get all diagnostics of current buffer in location list.
    nmap <silent> [g <Plug>(coc-diagnostic-prev)
    nmap <silent> ]g <Plug>(coc-diagnostic-next)

    " GoTo code navigation.
    nmap <silent> gd <Plug>(coc-definition)
    nmap <silent> gy <Plug>(coc-type-definition)
    nmap <silent> gi <Plug>(coc-implementation)
    nmap <silent> gr <Plug>(coc-references)

    " Use K to show documentation in preview window.
    nnoremap <silent> K :call ShowDocumentation()<CR>

    function! ShowDocumentation()
      if CocAction('hasProvider', 'hover')
        call CocActionAsync('doHover')
      else
        call feedkeys('K', 'in')
      endif
    endfunction

    " Highlight the symbol and its references when holding the cursor.
    autocmd CursorHold * silent call CocActionAsync('highlight')

    " Symbol renaming.
    nmap <leader>rn <Plug>(coc-rename)

    " Formatting selected code.
    xmap <leader>f  <Plug>(coc-format-selected)
    nmap <leader>f  <Plug>(coc-format-selected)

    augroup mygroup
      autocmd!
      " Setup formatexpr specified filetype(s).
      autocmd FileType typescript,json setl formatexpr=CocAction('formatSelected')
      " Update signature help on jump placeholder.
      autocmd User CocJumpPlaceholder call CocActionAsync('showSignatureHelp')
    augroup end

    " Applying codeAction to the selected region.
    " Example: `<leader>aap` for current paragraph
    xmap <leader>a  <Plug>(coc-codeaction-selected)
    nmap <leader>a  <Plug>(coc-codeaction-selected)

    " Remap keys for applying codeAction to the current buffer.
    nmap <leader>ac  <Plug>(coc-codeaction)
    " Apply AutoFix to problem on the current line.
    nmap <leader>qf  <Plug>(coc-fix-current)

    " Run the Code Lens action on the current line.
    nmap <leader>cl  <Plug>(coc-codelens-action)

    " Map function and class text objects
    " NOTE: Requires 'textDocument.documentSymbol' support from the language server.
    xmap if <Plug>(coc-funcobj-i)
    omap if <Plug>(coc-funcobj-i)
    xmap af <Plug>(coc-funcobj-a)
    omap af <Plug>(coc-funcobj-a)
    xmap ic <Plug>(coc-classobj-i)
    omap ic <Plug>(coc-classobj-i)
    xmap ac <Plug>(coc-classobj-a)
    omap ac <Plug>(coc-classobj-a)

    " Remap <C-f> and <C-b> for scroll float windows/popups.
    if has('nvim-0.4.0') || has('patch-8.2.0750')
      nnoremap <silent><nowait><expr> <C-f> coc#float#has_scroll() ? coc#float#scroll(1) : "\<C-f>"
      nnoremap <silent><nowait><expr> <C-b> coc#float#has_scroll() ? coc#float#scroll(0) : "\<C-b>"
      inoremap <silent><nowait><expr> <C-f> coc#float#has_scroll() ? "\<c-r>=coc#float#scroll(1)\<cr>" : "\<Right>"
      inoremap <silent><nowait><expr> <C-b> coc#float#has_scroll() ? "\<c-r>=coc#float#scroll(0)\<cr>" : "\<Left>"
      vnoremap <silent><nowait><expr> <C-f> coc#float#has_scroll() ? coc#float#scroll(1) : "\<C-f>"
      vnoremap <silent><nowait><expr> <C-b> coc#float#has_scroll() ? coc#float#scroll(0) : "\<C-b>"
    endif

    " Use CTRL-S for selections ranges.
    " Requires 'textDocument/selectionRange' support of language server.
    nmap <silent> <C-s> <Plug>(coc-range-select)
    xmap <silent> <C-s> <Plug>(coc-range-select)

    " Add `:Format` command to format current buffer.
    command! -nargs=0 Format :call CocActionAsync('format')

    " Add `:Fold` command to fold current buffer.
    command! -nargs=? Fold :call     CocAction('fold', <f-args>)

    " Add `:OR` command for organize imports of the current buffer.
    command! -nargs=0 OR   :call     CocActionAsync('runCommand', 'editor.action.organizeImport')

    " Add (Neo)Vim's native statusline support.
    " NOTE: Please see `:h coc-status` for integrations with external plugins that
    " provide custom statusline: lightline.vim, vim-airline.
    "set statusline^=%{coc#status()}%{get(b:,'coc_current_function','')}

    " Mappings for CoCList
    " Show all diagnostics.
    nnoremap <silent><nowait> <space>a  :<C-u>CocList diagnostics<cr>
    " Manage extensions.
    "nnoremap <silent><nowait> <space>e  :<C-u>CocList extensions<cr>
    " Show commands.
    nnoremap <silent><nowait> <space>c  :<C-u>CocList commands<cr>
    " Find symbol of current document.
    nnoremap <silent><nowait> <space>o  :<C-u>CocList outline<cr>
    " Search workspace symbols.
    nnoremap <silent><nowait> <space>s  :<C-u>CocList -I symbols<cr>
    " Do default action for next item.
    nnoremap <silent><nowait> <space>j  :<C-u>CocNext<CR>
    " Do default action for previous item.
    nnoremap <silent><nowait> <space>k  :<C-u>CocPrev<CR>
    " Resume latest coc list.
    nnoremap <silent><nowait> <space>p  :<C-u>CocListResume<CR>

    " -- Extensions -- "
    nnoremap <space>e <Cmd>CocCommand explorer<CR>
endif

" these "Ctrl mappings" work well when Caps Lock is mapped to Ctrl
nmap <leader>tn :TestNearest<CR>
nmap <leader>tf :TestFile<CR>
nmap <leader>ts :TestSuite<CR>
nmap <leader>tl :TestLast<CR>
nmap <leader>tg :TestVisit<CR>

" ------------ Highlight/Color/Theme ------------- "
colorscheme vim
set background=dark
highlight Normal guibg=NONE guifg=white
highlight SignColumn ctermbg=NONE guibg=NONE

" 80 char border
highlight colorcolumn ctermbg=235 guibg=#262626

" hybrid line number
highlight CursorLine gui=reverse
highlight CursorLineNR cterm=NONE ctermfg=214 guifg=#ffaf00
highlight CursorColumn guibg=#4e4e4e

" vertical split
highlight VertSplit cterm=NONE ctermfg=123 gui=NONE guifg=#87ffff

" comment color
highlight Comment ctermfg=248 guifg=#a8a8a8

" autocomplete highlights
highlight Pmenu ctermbg=236 ctermfg=254 guibg=#303030 guifg=#e4e4e4
highlight PmenuSel ctermbg=232 ctermfg=252 guibg=#080808 guifg=#d0d0d0

highlight MatchParen ctermbg=24 guibg=#005f87
highlight Search ctermbg=239 ctermfg=NONE guibg=#3a3a3a guifg=NONE
highlight Visual ctermbg=18 guibg=#000087

" coc
highlight CocWarningSign ctermfg=172 guifg=#d78700

" ------------ Plugin Settings ------------------- "
" vim-code-dark plugin
let g:airline_theme = 'codedark'


" gitgutter plugin
highlight GitGutterAdd      cterm=bold ctermfg=2 gui=bold guifg=#00ff00 guibg=NONE
highlight GitGutterDelete   cterm=bold ctermfg=1 gui=bold guifg=#ff0000 guibg=NONE
highlight GitGutterChange   cterm=bold ctermfg=3 gui=bold guifg=#ffff00 guibg=NONE
highlight GitGutterText     cterm=bold ctermfg=5 gui=bold guifg=#ff00ff guibg=NONE

" vim-fugitive plugin
highlight DiffAdd       cterm=NONE ctermbg=17 gui=NONE guibg=#00005f
highlight DiffDelete    cterm=NONE ctermbg=17 ctermfg=1 gui=NONE guibg=#00005f guifg=#5f0000
highlight DiffChange    cterm=NONE ctermbg=17 gui=NONE guibg=#00005f
highlight DiffText      cterm=NONE ctermbg=52 gui=NONE guibg=#00005f

" error color
highlight error ctermbg=88 guibg=#870000
highlight SpellBad ctermbg=88 guibg=#870000
highlight todo ctermbg=100 guibg=#878700

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
let g:airline_symbols.linenr = ' '
let g:airline_symbols.maxlinenr = ''
let g:airline_symbols.colnr = ':'
let g:airline#extensions#hunks#enabled = 0
let g:airline#extensions#tabline#enabled = 1

" NERDTree ignore
"let NERDTreeIgnore = ['\.pyc$', '\.class']

" closetag
let g:closetag_filenames = '*.html,*.xhtml,*.phtml,*.js,*.jsx,*.vue'

" ------------ Mapping / Remaped keys ------------ "
" change default up and down by line breaks
" https://vim.fandom.com/wiki/Move_through_wrapped_lines
"inoremap <silent> <Down> <C-o>gj
"inoremap <silent> <Up> <C-o>gk
noremap <silent> j gj
noremap <silent> k gk

" save with ctrl-s
nnoremap ZX :w<CR>

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
noremap <silent> <C-Up>     :resize -2<CR>
noremap <silent> <C-Down>   :resize +2<CR>
noremap <silent> <C-Left>   :vertical:resize -3<CR>
noremap <silent> <C-Right>  :vertical:resize +3<CR>

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
noremap <C-z> :call fzf#run(fzf#wrap({'source': $FZF_VIM_COMMAND}))<CR>

" NERDTree plugin
"noremap <Leader>n :NERDTreeToggle<CR>

" vim fugitive
noremap <Leader>gs :G<CR>
noremap <Leader>gd :Gdiff<CR>

" open terminal like vscode
noremap <Leader>term :10 split term://zsh<CR>A
noremap <Leader>vterm :10 vsplit term://zsh<CR>A

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
    "autocmd BufRead,BufNewFile *.jsx,*.js setlocal filetype=javascript
    autocmd BufRead,BufNewFile *.md,*.mdx setlocal filetype=markdown
augroup end

augroup postWrite
    au!
    " auto reload vimrc
    autocmd BufWritePost .vimrc source ~/.vimrc
    " xrdb autoload .Xresources
    autocmd BufWritePost .Xresources silent !xrdb ~/.Xresources
augroup end

"augroup toggleCocExtensions
"    autocmd!
"    function CommandTsserver(command)
"        let stats = CocAction('extensionStats')
"        if filter(stats, 'v:val["id"] == "coc-tsserver"')[0]['state'] != 'disabled'
"            call CocAction(a:command, 'coc-tsserver')
"        endif
"    endfunction
"    autocmd BufEnter *.vue,*.spec.ts call CommandTsserver('deactivateExtension')
"    autocmd BufLeave *.vue,*.spec.ts call CommandTsserver('activeExtension')
"augroup end
