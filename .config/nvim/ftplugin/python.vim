setlocal sw=4 ts=4 sts=4 expandtab
" mapping
map <buffer> <F5> :w<CR> :!python3 '%'<CR>
map <buffer> <F15> :w<CR> :term python3 -i '%'<CR>

map <buffer> <Leader>pr oprint()<Esc>i
vmap <buffer> <Leader>pr yoprint()<Esc>Pl
