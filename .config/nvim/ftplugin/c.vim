" shortcut to compile and run
map <buffer> <F5> :w<CR> :! gcc '%' -o '/tmp/nvim-c' && /tmp/nvim-c<CR>
