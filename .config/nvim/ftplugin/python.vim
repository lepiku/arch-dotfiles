setlocal sw=4 ts=4 sts=4 expandtab
" mapping
map <F5> :w<CR>:!python3 '%'<CR>
map <Leader><F5> :w<CR>:!python3 -i '%'<CR>

map <Leader>pr oprint()<Esc>i
vmap <Leader>pr yoprint()<Esc>Pl

